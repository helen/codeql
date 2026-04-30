/**
 * Provides the PHP SSA (Static Single Assignment) implementation using the shared SSA library.
 */
overlay[local]
module;

private import codeql.ssa.Ssa as SsaImplCommon
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.controlflow.BasicBlocks as BasicBlocks
private import codeql.php.controlflow.internal.CfgImpl as CfgImpl
private import codeql.Locations

private class BasicBlock = BasicBlocks::Cfg::BasicBlock;

// =============================================================================
// Source variables: canonical (scope, name) identity
// =============================================================================

/** Gets the CFG scope enclosing `n`. */
private CfgImpl::CfgScope::CfgScope getEnclosingScope(Php::AstNode n) {
  exists(Php::AstNode parent | parent = n.getParent() |
    result = parent
    or
    not parent instanceof CfgImpl::CfgScope::CfgScope and result = getEnclosingScope(parent)
  )
}

private newtype TPhpSourceVariable =
  MkPhpSourceVariable(CfgImpl::CfgScope::CfgScope scope, string name) {
    exists(Php::VariableName vn |
      name = vn.getChild().getValue() and
      scope = getEnclosingScope(vn) and
      not vn.getParent() instanceof Php::DynamicVariableName
    )
  }

/**
 * A PHP source variable: a local variable identified canonically by name and scope.
 */
class PhpSourceVariable extends TPhpSourceVariable {
  CfgImpl::CfgScope::CfgScope scope;
  string name;

  PhpSourceVariable() { this = MkPhpSourceVariable(scope, name) }

  /** Gets the scope this variable belongs to. */
  CfgImpl::CfgScope::CfgScope getScope() { result = scope }

  /** Gets the variable name (without $). */
  string getVariableName() { result = name }

  string toString() { result = "$" + name }

  Location getLocation() { result = scope.getLocation() }
}

/** Gets the source variable for a given VariableName node. */
private PhpSourceVariable getSourceVariable(Php::VariableName vn) {
  result = MkPhpSourceVariable(getEnclosingScope(vn), vn.getChild().getValue())
}

// =============================================================================
// Variable writes
// =============================================================================

/**
 * Holds if `write` is a write to the variable represented by `sv`, via VariableName `var`.
 */
private predicate variableWriteAt(Php::AstNode write, PhpSourceVariable sv) {
  exists(Php::VariableName var |
    sv = getSourceVariable(var) and
    (
      // Simple assignment: $x = expr
      var = write.(Php::AssignmentExpression).getLeft()
      or
      // Augmented assignment: $x += expr (also a write)
      var = write.(Php::AugmentedAssignmentExpression).getLeft()
      or
      // Reference assignment: $x =& expr
      var = write.(Php::ReferenceAssignmentExpression).getLeft()
      or
      // Update expression: ++$x, $x++, --$x, $x--
      var = write.(Php::UpdateExpression).getArgument()
      or
      // Static variable declaration: static $x = expr
      var = write.(Php::StaticVariableDeclaration).getName()
    )
  )
  or
  // Catch clause: catch (Exception $e)
  exists(Php::CatchClause catch_ |
    write = catch_ and
    sv = getSourceVariable(catch_.getName())
  )
  or
  // Foreach: the value/key variables (children after index 0 which is the iterable)
  exists(Php::ForeachStatement foreach, int idx |
    write = foreach and
    idx > 0 and
    exists(Php::VariableName var |
      var = foreach.getChild(idx) and
      sv = getSourceVariable(var)
    )
  )
}

/**
 * Holds if `param` is a parameter definition that writes to variable `sv`.
 */
private predicate isParameterWrite(Php::SimpleParameter param, PhpSourceVariable sv) {
  sv = getSourceVariable(param.getName())
}

// =============================================================================
// Variable reads
// =============================================================================

/**
 * Holds if `var` (a VariableName node) is a read of a variable.
 * A read is any VariableName that is NOT exclusively a write target.
 */
private predicate variableReadAt(Php::VariableName var, PhpSourceVariable sv) {
  sv = getSourceVariable(var) and
  not var = any(Php::AssignmentExpression a).getLeft() and
  not var = any(Php::ReferenceAssignmentExpression a).getLeft() and
  not var = any(Php::SimpleParameter p).getName() and
  not var = any(Php::CatchClause c).getName() and
  not var = any(Php::StaticVariableDeclaration d).getName() and
  not var.getParent() instanceof Php::DynamicVariableName and
  // Exclude foreach binding variables (index > 0 children)
  not exists(Php::ForeachStatement foreach, int idx |
    idx > 0 and var = foreach.getChild(idx)
  )
  // Note: augmented assignment LHS ($x += ...) is both read and write,
  // so we do NOT exclude it here. Update expression argument is also a read.
}

// =============================================================================
// SSA Input implementation
// =============================================================================

module SsaInput implements SsaImplCommon::InputSig<Location, BasicBlocks::Cfg::BasicBlock> {
  class SourceVariable = PhpSourceVariable;

  predicate variableWrite(BasicBlock bb, int i, SourceVariable v, boolean certain) {
    // Assignment/update/catch/foreach at a specific CFG node position
    exists(Php::AstNode write |
      variableWriteAt(write, v) and
      bb.getNode(i).getAstNode() = write and
      certain = true
    )
    or
    // Parameter initializations: modeled at index -1 in entry block
    exists(Php::SimpleParameter param |
      isParameterWrite(param, v) and
      bb instanceof BasicBlocks::EntryBasicBlock and
      bb.getFirstNode().getScope() = v.getScope() and
      i = -1 and
      certain = true
    )
  }

  predicate variableRead(BasicBlock bb, int i, SourceVariable v, boolean certain) {
    exists(Php::VariableName var |
      variableReadAt(var, v) and
      bb.getNode(i).getAstNode() = var and
      certain = true
    )
  }
}

import SsaImplCommon::Make<Location, BasicBlocks::Cfg, SsaInput> as Impl

class Definition = Impl::Definition;

class WriteDefinition = Impl::WriteDefinition;

class UncertainWriteDefinition = Impl::UncertainWriteDefinition;

class PhiNode = Impl::PhiNode;

module Consistency = Impl::Consistency;

/**
 * Holds if SSA definition `def` reaches a read at basic block `bb`, index `i`,
 * for variable `v`.
 */
predicate ssaDefReachesRead(PhpSourceVariable v, Definition def, BasicBlock bb, int i) {
  Impl::ssaDefReachesRead(v, def, bb, i)
}

/**
 * Gets a read of SSA definition `def`.
 */
BasicBlocks::CfgNode getARead(Definition def) {
  exists(PhpSourceVariable v, BasicBlock bb, int i |
    ssaDefReachesRead(v, def, bb, i) and
    result = bb.getNode(i)
  )
}

/**
 * Holds if the value defined at SSA definition `def` can reach a read at `read`,
 * without passing through any other read.
 */
predicate firstRead(Definition def, BasicBlocks::CfgNode read) {
  exists(BasicBlock bb, int i | Impl::firstUse(def, bb, i, true) and read = bb.getNode(i))
}

/**
 * Holds if the read at `read2` is a read of the same SSA definition `def`
 * as the read at `read1`, and `read2` can be reached from `read1` without
 * passing through another read.
 */
predicate adjacentReadPair(Definition def, BasicBlocks::CfgNode read1, BasicBlocks::CfgNode read2) {
  exists(BasicBlock bb1, int i1, BasicBlock bb2, int i2, PhpSourceVariable v |
    Impl::ssaDefReachesRead(v, def, bb1, i1) and
    Impl::adjacentUseUse(bb1, i1, bb2, i2, v, true) and
    read1 = bb1.getNode(i1) and
    read2 = bb2.getNode(i2)
  )
}
