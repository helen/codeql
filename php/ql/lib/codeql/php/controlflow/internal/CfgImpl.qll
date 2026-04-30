/**
 * Provides the PHP-specific CFG implementation using the shared controlflow library.
 */
overlay[local]
module;

private import codeql.php.ast.internal.TreeSitter
private import codeql.controlflow.Cfg as CfgShared
private import codeql.Locations
private import Completion

/** CFG scope: each gets its own control flow graph. */
module CfgScope {
  abstract class CfgScope extends Php::AstNode { }

  private class FunctionScope extends CfgScope instanceof Php::FunctionDefinition { }

  private class MethodScope extends CfgScope instanceof Php::MethodDeclaration { }

  private class AnonymousFunctionScope extends CfgScope instanceof Php::AnonymousFunction { }

  private class ArrowFunctionScope extends CfgScope instanceof Php::ArrowFunction { }

  private class ProgramScope extends CfgScope instanceof Php::Program { }
}

// Stable IDs for AST nodes (used by shared CFG library for join-predecessor ordering)
private predicate id(Php::AstNode node1, Php::AstNode node2) { node1 = node2 }

private predicate idOf(Php::AstNode node, int i) = equivalenceRelation(id/2)(node, i)

/** The InputSig implementation for PHP. */
private module CfgInput implements CfgShared::InputSig<Location> {
  private import CfgImpl as Impl

  import Completion
  import CfgScope

  class AstNode = Php::AstNode;

  predicate completionIsNormal(Completion c) { c instanceof NormalCompletion }

  predicate completionIsSimple(Completion c) { c instanceof SimpleCompletion }

  predicate completionIsValidFor(Completion c, AstNode n) { c.isValidFor(n) }

  CfgScope getCfgScope(AstNode n) {
    exists(Php::AstNode parent | parent = n.getParent() |
      result = parent
      or
      not parent instanceof CfgScope and result = getCfgScope(parent)
    )
  }

  predicate scopeFirst(CfgScope scope, AstNode first) {
    scope.(Impl::CfgScopeImpl).entry(first)
  }

  predicate scopeLast(CfgScope scope, AstNode last, Completion c) {
    scope.(Impl::CfgScopeImpl).exit(last, c)
  }

  SuccessorType getAMatchingSuccessorType(Completion c) { result = c.getAMatchingSuccessorType() }

  int idOfAstNode(AstNode node) { idOf(node, result) }

  int idOfCfgScope(CfgScope scope) { result = idOfAstNode(scope) }
}

import CfgShared::Make<Location, CfgInput>

/** Base class for CFG scope implementations. */
abstract class CfgScopeImpl extends Php::AstNode {
  abstract predicate entry(Php::AstNode first);

  abstract predicate exit(Php::AstNode last, Completion c);
}

private class ProgramScopeImpl extends CfgScopeImpl instanceof Php::Program {
  override predicate entry(Php::AstNode n) {
    first(this.(Php::Program).getChild(0), n)
    or
    not exists(this.(Php::Program).getChild(_)) and n = this
  }

  override predicate exit(Php::AstNode last, Completion c) {
    exists(int maxIdx |
      maxIdx = max(int i | exists(this.(Php::Program).getChild(i))) and
      last(this.(Php::Program).getChild(maxIdx), last, c)
    )
    or
    not exists(this.(Php::Program).getChild(_)) and last = this and c instanceof SimpleCompletion
  }
}

private class FunctionScopeImpl extends CfgScopeImpl instanceof Php::FunctionDefinition {
  override predicate entry(Php::AstNode n) {
    first(this.(Php::FunctionDefinition).getBody(), n)
  }

  override predicate exit(Php::AstNode last, Completion c) {
    last(this.(Php::FunctionDefinition).getBody(), last, c)
  }
}

private class MethodScopeImpl extends CfgScopeImpl instanceof Php::MethodDeclaration {
  override predicate entry(Php::AstNode n) {
    first(this.(Php::MethodDeclaration).getBody(), n)
  }

  override predicate exit(Php::AstNode last, Completion c) {
    last(this.(Php::MethodDeclaration).getBody(), last, c)
  }
}

private class AnonymousFunctionScopeImpl extends CfgScopeImpl instanceof Php::AnonymousFunction {
  override predicate entry(Php::AstNode n) {
    first(this.(Php::AnonymousFunction).getBody(), n)
  }

  override predicate exit(Php::AstNode last, Completion c) {
    last(this.(Php::AnonymousFunction).getBody(), last, c)
  }
}

private class ArrowFunctionScopeImpl extends CfgScopeImpl instanceof Php::ArrowFunction {
  override predicate entry(Php::AstNode n) {
    first(this.(Php::ArrowFunction).getBody(), n)
  }

  override predicate exit(Php::AstNode last, Completion c) {
    last(this.(Php::ArrowFunction).getBody(), last, c)
  }
}

// =============================================================================
// CFG tree classes using shared library helpers
// =============================================================================

/** A compound statement — sequential execution of children. */
private class CompoundStatementTree extends StandardPreOrderTree instanceof Php::CompoundStatement {
  override ControlFlowTree getChildNode(int i) { result = super.getChild(i) }
}

/** An expression statement. */
private class ExpressionStatementTree extends StandardPreOrderTree instanceof Php::ExpressionStatement
{
  override ControlFlowTree getChildNode(int i) { i = 0 and result = super.getChild() }
}

/** An echo statement. */
private class EchoStatementTree extends StandardPreOrderTree instanceof Php::EchoStatement {
  override ControlFlowTree getChildNode(int i) { i = 0 and result = super.getChild() }
}

/** A return statement — evaluate return value, then return. */
private class ReturnStatementTree extends PostOrderTree instanceof Php::ReturnStatement {
  override predicate first(Php::AstNode first) {
    first(super.getChild(), first)
    or
    not exists(super.getChild()) and first = this
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    last(super.getChild(), pred, c) and
    c instanceof NormalCompletion and
    succ = this
  }

  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof ReturnCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getChild()
  }
}

/** A throw expression. */
private class ThrowExpressionTree extends PostOrderTree instanceof Php::ThrowExpression {
  override predicate first(Php::AstNode first) {
    first(super.getChild(), first)
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    last(super.getChild(), pred, c) and
    c instanceof NormalCompletion and
    succ = this
  }

  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof ThrowCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getChild()
  }
}

/** A break statement. */
private class BreakStatementTree extends LeafTree instanceof Php::BreakStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof BreakCompletion
  }
}

/** A continue statement. */
private class ContinueStatementTree extends LeafTree instanceof Php::ContinueStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof ContinueCompletion
  }
}

/** An if statement. */
private class IfStatementTree extends PreOrderTree instanceof Php::IfStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last(super.getBody(), last, c)
    or
    last(super.getAlternative(_), last, c)
    or
    last(super.getCondition(), last, c) and
    c instanceof FalseCompletion and
    not exists(super.getAlternative(_))
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getCondition() or
    child = super.getBody() or
    child = super.getAlternative(_)
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    pred = this and first(super.getCondition(), succ) and c instanceof SimpleCompletion
    or
    last(super.getCondition(), pred, c) and
    c instanceof TrueCompletion and
    first(super.getBody(), succ)
    or
    last(super.getCondition(), pred, c) and
    c instanceof FalseCompletion and
    first(super.getAlternative(0), succ)
  }
}

/** A while statement. */
private class WhileStatementTree extends PreOrderTree instanceof Php::WhileStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last(super.getCondition(), last, c) and c instanceof FalseCompletion
    or
    last(super.getBody(), last, c) and c instanceof BreakCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getCondition() or child = super.getBody()
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    pred = this and first(super.getCondition(), succ) and c instanceof SimpleCompletion
    or
    last(super.getCondition(), pred, c) and
    c instanceof TrueCompletion and
    first(super.getBody(), succ)
    or
    last(super.getBody(), pred, c) and
    (c instanceof NormalCompletion or c instanceof ContinueCompletion) and
    first(super.getCondition(), succ)
  }
}

/** A do-while statement. */
private class DoStatementTree extends PreOrderTree instanceof Php::DoStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last(super.getCondition(), last, c) and c instanceof FalseCompletion
    or
    last(super.getBody(), last, c) and c instanceof BreakCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getCondition() or child = super.getBody()
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    pred = this and first(super.getBody(), succ) and c instanceof SimpleCompletion
    or
    last(super.getBody(), pred, c) and
    (c instanceof NormalCompletion or c instanceof ContinueCompletion) and
    first(super.getCondition(), succ)
    or
    last(super.getCondition(), pred, c) and
    c instanceof TrueCompletion and
    first(super.getBody(), succ)
  }
}

/** A for statement. */
private class ForStatementTree extends PreOrderTree instanceof Php::ForStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last(super.getCondition(), last, c) and c instanceof FalseCompletion
    or
    last(super.getBody(_), last, c) and c instanceof BreakCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getInitialize() or
    child = super.getCondition() or
    child = super.getBody(_) or
    child = super.getUpdate()
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    // entry -> init or condition or body
    pred = this and
    c instanceof SimpleCompletion and
    (
      first(super.getInitialize(), succ)
      or
      not exists(super.getInitialize()) and first(super.getCondition(), succ)
      or
      not exists(super.getInitialize()) and not exists(super.getCondition()) and
      first(super.getBody(0), succ)
    )
    or
    // init -> condition or body
    last(super.getInitialize(), pred, c) and
    c instanceof NormalCompletion and
    (
      first(super.getCondition(), succ)
      or
      not exists(super.getCondition()) and first(super.getBody(0), succ)
    )
    or
    // condition true -> body
    last(super.getCondition(), pred, c) and
    c instanceof TrueCompletion and
    first(super.getBody(0), succ)
    or
    // body -> update or condition or body (loop)
    last(super.getBody(_), pred, c) and
    (c instanceof NormalCompletion or c instanceof ContinueCompletion) and
    (
      first(super.getUpdate(), succ)
      or
      not exists(super.getUpdate()) and first(super.getCondition(), succ)
      or
      not exists(super.getUpdate()) and not exists(super.getCondition()) and
      first(super.getBody(0), succ)
    )
    or
    // update -> condition or body
    last(super.getUpdate(), pred, c) and
    c instanceof NormalCompletion and
    (
      first(super.getCondition(), succ)
      or
      not exists(super.getCondition()) and first(super.getBody(0), succ)
    )
  }
}

/** A foreach statement. */
private class ForeachStatementTree extends PreOrderTree instanceof Php::ForeachStatement {
  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof SimpleCompletion
    or
    last(super.getBody(), last, c) and c instanceof BreakCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getChild(0) or child = super.getBody()
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    pred = this and first(super.getChild(0), succ) and c instanceof SimpleCompletion
    or
    last(super.getChild(0), pred, c) and
    c instanceof NormalCompletion and
    first(super.getBody(), succ)
    or
    last(super.getBody(), pred, c) and
    (c instanceof NormalCompletion or c instanceof ContinueCompletion) and
    succ = this
  }
}

/** A switch statement. */
private class SwitchStatementTree extends PreOrderTree instanceof Php::SwitchStatement {
  override predicate last(Php::AstNode last, Completion c) {
    exists(Php::AstNode caseNode |
      caseNode = super.getBody().getChild(_) and
      last(caseNode, last, c) and
      (c instanceof NormalCompletion or c instanceof BreakCompletion)
    )
    or
    last(super.getCondition(), last, c)
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getCondition() or child = super.getBody().getChild(_)
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    pred = this and first(super.getCondition(), succ) and c instanceof SimpleCompletion
    or
    last(super.getCondition(), pred, c) and
    c instanceof NormalCompletion and
    first(super.getBody().getChild(0), succ)
    or
    exists(int i |
      last(super.getBody().getChild(i), pred, c) and
      c instanceof NormalCompletion and
      first(super.getBody().getChild(i + 1), succ)
    )
  }
}

/** A try statement. */
private class TryStatementTree extends PreOrderTree instanceof Php::TryStatement {
  private Php::CatchClause getACatchClause() {
    result = super.getChild(_)
  }

  private Php::FinallyClause getFinallyClause() {
    result = super.getChild(_)
  }

  override predicate last(Php::AstNode last, Completion c) {
    exists(this.getFinallyClause()) and
    last(this.getFinallyClause().getBody(), last, c)
    or
    not exists(this.getFinallyClause()) and
    (
      last(super.getBody(), last, c) and c instanceof NormalCompletion
      or
      last(this.getACatchClause().getBody(), last, c)
    )
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = super.getBody() or
    child = this.getACatchClause().getBody() or
    child = this.getFinallyClause().getBody()
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    pred = this and first(super.getBody(), succ) and c instanceof SimpleCompletion
    or
    // try throws -> first catch
    last(super.getBody(), pred, c) and
    c instanceof ThrowCompletion and
    exists(Php::CatchClause firstCatch |
      firstCatch = super.getChild(min(int i | super.getChild(i) instanceof Php::CatchClause)) and
      first(firstCatch.getBody(), succ)
    )
    or
    // try normal -> finally
    last(super.getBody(), pred, c) and
    c instanceof NormalCompletion and
    exists(this.getFinallyClause()) and
    first(this.getFinallyClause().getBody(), succ)
    or
    // catch -> finally
    last(this.getACatchClause().getBody(), pred, c) and
    c instanceof NormalCompletion and
    exists(this.getFinallyClause()) and
    first(this.getFinallyClause().getBody(), succ)
  }
}

/**
 * Default tree for AST nodes not handled by specific tree classes.
 * Tokens are leaves; everything else executes children in source order.
 */
private class TokenTree extends LeafTree instanceof Php::Token { }

/**
 * Default handling for non-token, non-specific AST nodes.
 * Executes children in source order (pre-order: enters node, then children).
 */
private class DefaultTree extends StandardPreOrderTree instanceof Php::AstNode {
  DefaultTree() {
    not this instanceof Php::Token and
    not this instanceof Php::CompoundStatement and
    not this instanceof Php::ExpressionStatement and
    not this instanceof Php::EchoStatement and
    not this instanceof Php::ReturnStatement and
    not this instanceof Php::ThrowExpression and
    not this instanceof Php::BreakStatement and
    not this instanceof Php::ContinueStatement and
    not this instanceof Php::IfStatement and
    not this instanceof Php::WhileStatement and
    not this instanceof Php::DoStatement and
    not this instanceof Php::ForStatement and
    not this instanceof Php::ForeachStatement and
    not this instanceof Php::SwitchStatement and
    not this instanceof Php::TryStatement
  }

  override ControlFlowTree getChildNode(int i) {
    result =
      rank[i + 1](Php::AstNode child |
        child = super.getAFieldOrChild() and not child instanceof Php::Token
      |
        child
        order by
          child.getLocation().getStartLine(), child.getLocation().getStartColumn()
      )
  }
}
