/**
 * Provides the PHP-specific CFG implementation using the shared controlflow library.
 */

private import codeql.php.ast.internal.TreeSitter as Php
private import codeql.controlflow.Cfg as CfgShared
private import codeql.Locations
private import Completion

/** CFG scope: each gets its own control flow graph. */
module CfgScope {
  abstract class CfgScope extends Php::AstNode { }

  class FunctionScope extends CfgScope instanceof Php::FunctionDefinition { }

  class MethodScope extends CfgScope instanceof Php::MethodDeclaration { }

  class AnonymousFunctionScope extends CfgScope instanceof Php::AnonymousFunction { }

  class ArrowFunctionScope extends CfgScope instanceof Php::ArrowFunction { }

  class ProgramScope extends CfgScope instanceof Php::Program { }
}

/** The InputSig implementation for PHP. */
private module CfgInput implements CfgShared::InputSig<Location> {
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
    first(scope.(Php::Program), first) or
    first(scope.(Php::FunctionDefinition), first) or
    first(scope.(Php::MethodDeclaration), first) or
    first(scope.(Php::AnonymousFunction), first) or
    first(scope.(Php::ArrowFunction), first)
  }

  predicate scopeLast(CfgScope scope, AstNode last, Completion c) {
    last(scope.(Php::Program), last, c) or
    last(scope.(Php::FunctionDefinition), last, c) or
    last(scope.(Php::MethodDeclaration), last, c) or
    last(scope.(Php::AnonymousFunction), last, c) or
    last(scope.(Php::ArrowFunction), last, c)
  }

  SuccessorType getAMatchingSuccessorType(Completion c) { result = c.getAMatchingSuccessorType() }

  int idOfAstNode(AstNode node) { none() }

  int idOfCfgScope(CfgScope scope) { none() }
}

// No splitting for initial implementation
private module SplittingInput implements CfgShared::SplittingInputSig<Location, CfgInput> {
  private newtype TSplitKindBase = TNoSplitKind()

  class SplitKindBase = TSplitKindBase;

  private newtype TSplit = TNoSplit()

  class Split extends TSplit {
    string toString() { none() }
  }

  int maxSplits() { result = 0 }
}

private module ConditionalCompletionSplittingInput implements
  CfgShared::ConditionalCompletionSplittingInputSig<Location, CfgInput, SplittingInput>
{
  class ConditionalCompletion extends Completion, BooleanCompletion { }

  class ConditionalCompletionSplitKind extends SplittingInput::SplitKindBase, TNoSplitKind { }

  class ConditionalCompletionSplit extends SplittingInput::Split, TNoSplit {
    ConditionalCompletion getCompletion() { none() }
  }

  predicate condPropagateExpr(
    Php::AstNode parent, ConditionalCompletion parentCompletion, Php::AstNode child,
    ConditionalCompletion childCompletion
  ) {
    none()
  }
}

module CfgImpl =
  CfgShared::MakeWithSplitting<Location, CfgInput, SplittingInput, ConditionalCompletionSplittingInput>;

private import CfgImpl

// =============================================================================
// Helper predicates
// =============================================================================

/**
 * Holds if `child` is an executable child of `parent` — an expression or statement
 * that should participate in the CFG. Excludes type annotations, modifiers, names
 * in declarations, and other non-executable syntax.
 */
private predicate isExecutableChild(Php::AstNode parent, Php::AstNode child) {
  child = parent.getAFieldOrChild() and
  (child instanceof Php::Expression or child instanceof Php::Statement)
}

/**
 * Gets the `i`th executable child of `parent`, ordered by source location.
 */
private Php::AstNode getExecutableChildByIndex(Php::AstNode parent, int i) {
  result =
    rank[i + 1](Php::AstNode child |
      isExecutableChild(parent, child)
    |
      child
      order by
        child.getLocation().getStartLine(), child.getLocation().getStartColumn(),
        child.getLocation().getEndLine(), child.getLocation().getEndColumn()
    )
}

// =============================================================================
// Leaf trees (tokens that can appear in executable positions)
// =============================================================================

private class TokenLeaf extends LeafTree instanceof Php::Token { }

// =============================================================================
// Scope trees (callables — their body is the first/last)
// =============================================================================

private class ProgramTree extends StandardPreOrderTree instanceof Php::Program {
  override ControlFlowTree getChildNode(int i) {
    result = getExecutableChildByIndex(this, i)
  }
}

private class FunctionDefinitionTree extends StandardPreOrderTree instanceof Php::FunctionDefinition {
  override ControlFlowTree getChildNode(int i) {
    // Only the body (CompoundStatement) is executable within the function scope
    i = 0 and result = this.(Php::FunctionDefinition).getBody()
  }
}

private class MethodDeclarationTree extends StandardPreOrderTree instanceof Php::MethodDeclaration {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::MethodDeclaration).getBody()
  }
}

private class AnonymousFunctionTree extends StandardPreOrderTree instanceof Php::AnonymousFunction {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::AnonymousFunction).getBody()
  }
}

private class ArrowFunctionTree extends StandardPostOrderTree instanceof Php::ArrowFunction {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::ArrowFunction).getBody()
  }
}

// =============================================================================
// Statement trees
// =============================================================================

/** Compound statement (block): sequential execution of children. */
private class CompoundStatementTree extends StandardPreOrderTree instanceof Php::CompoundStatement {
  override ControlFlowTree getChildNode(int i) {
    result = this.(Php::CompoundStatement).getChild(i)
  }
}

/** Expression statement: execute the expression. */
private class ExpressionStatementTree extends StandardPreOrderTree instanceof Php::ExpressionStatement {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::ExpressionStatement).getChild()
  }
}

/** Echo statement: execute the argument expressions left to right. */
private class EchoStatementTree extends StandardPreOrderTree instanceof Php::EchoStatement {
  override ControlFlowTree getChildNode(int i) {
    result = this.(Php::EchoStatement).getChild(i)
  }
}

/** Return statement: evaluate the expression, then complete with ReturnCompletion. */
private class ReturnStatementTree extends StandardPostOrderTree instanceof Php::ReturnStatement {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::ReturnStatement).getChild()
  }

  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof ReturnCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) { none() }
}

/** Break statement: immediately completes with BreakCompletion. */
private class BreakStatementTree extends LeafTree instanceof Php::BreakStatement { }

/** Continue statement: immediately completes with ContinueCompletion. */
private class ContinueStatementTree extends LeafTree instanceof Php::ContinueStatement { }

// =============================================================================
// Conditional statements
// =============================================================================

/**
 * If statement:
 *   condition → [true] → then-body → exit
 *   condition → [false] → else/elseif → exit (or exit directly if no alternative)
 */
private class IfStatementTree extends ControlFlowTree instanceof Php::IfStatement {
  private Php::AstNode getCondition() {
    result = this.(Php::IfStatement).getCondition()
  }

  private Php::AstNode getThenBranch() {
    result = this.(Php::IfStatement).getBody()
  }

  private Php::AstNode getAlternative() {
    result = this.(Php::IfStatement).getAlternative(0)
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = this.getCondition() or
    child = this.getThenBranch() or
    child = this.getAlternative()
  }

  override predicate first(Php::AstNode first) {
    first(this.getCondition(), first)
  }

  override predicate last(Php::AstNode last, Completion c) {
    // Then branch completes
    last(this.getThenBranch(), last, c) and completionIsNormal(c)
    or
    // Alternative completes
    last(this.getAlternative(), last, c) and completionIsNormal(c)
    or
    // No alternative: condition exits the if with simple completion
    not exists(this.getAlternative()) and
    last(this.getCondition(), last, c) and
    c instanceof SimpleCompletion
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    // Condition → then branch
    last(this.getCondition(), pred, c) and
    c instanceof SimpleCompletion and
    first(this.getThenBranch(), succ)
    or
    // Condition → alternative (if exists)
    last(this.getCondition(), pred, c) and
    c instanceof SimpleCompletion and
    exists(this.getAlternative()) and
    first(this.getAlternative(), succ)
  }
}

/** Else clause: sequential execution of its body. */
private class ElseClauseTree extends StandardPreOrderTree instanceof Php::ElseClause {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::ElseClause).getBody()
  }
}

/** Else-if clause (treated like nested if within else). */
private class ElseIfClauseTree extends ControlFlowTree instanceof Php::ElseIfClause {
  private Php::AstNode getCondition() {
    result = this.(Php::ElseIfClause).getCondition()
  }

  private Php::AstNode getBody() {
    result = this.(Php::ElseIfClause).getBody()
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = this.getCondition() or child = this.getBody()
  }

  override predicate first(Php::AstNode first) {
    first(this.getCondition(), first)
  }

  override predicate last(Php::AstNode last, Completion c) {
    last(this.getBody(), last, c) and completionIsNormal(c)
    or
    last(this.getCondition(), last, c) and c instanceof SimpleCompletion
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    last(this.getCondition(), pred, c) and
    c instanceof SimpleCompletion and
    first(this.getBody(), succ)
  }
}

// =============================================================================
// Loop statements
// =============================================================================

/**
 * While statement:
 *   condition → [true] → body → condition (loop back)
 *   condition → [false/simple] → exit
 *   body break → exit
 *   body continue → condition
 */
private class WhileStatementTree extends ControlFlowTree instanceof Php::WhileStatement {
  private Php::AstNode getCondition() {
    result = this.(Php::WhileStatement).getCondition()
  }

  private Php::AstNode getBody() {
    result = this.(Php::WhileStatement).getBody()
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = this.getCondition()
  }

  override predicate first(Php::AstNode first) {
    first(this.getCondition(), first)
  }

  override predicate last(Php::AstNode last, Completion c) {
    // Loop exits when condition completes normally (approximation without boolean split)
    last(this.getCondition(), last, c) and c instanceof SimpleCompletion
    or
    // Break exits the loop
    last(this.getBody(), last, c) and c instanceof BreakCompletion
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    // Condition → body (on simple/normal completion)
    last(this.getCondition(), pred, c) and
    c instanceof SimpleCompletion and
    first(this.getBody(), succ)
    or
    // Body normal completion → back to condition (loop)
    last(this.getBody(), pred, c) and
    completionIsNormal(c) and
    first(this.getCondition(), succ)
    or
    // Body continue → back to condition
    last(this.getBody(), pred, c) and
    c instanceof ContinueCompletion and
    first(this.getCondition(), succ)
  }
}

/**
 * Do-while statement:
 *   body → condition → [true] → body (loop back)
 *   condition → [false/simple] → exit
 */
private class DoStatementTree extends ControlFlowTree instanceof Php::DoStatement {
  private Php::AstNode getBody() {
    result = this.(Php::DoStatement).getBody()
  }

  private Php::AstNode getCondition() {
    result = this.(Php::DoStatement).getCondition()
  }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = this.getCondition()
  }

  override predicate first(Php::AstNode first) {
    first(this.getBody(), first)
  }

  override predicate last(Php::AstNode last, Completion c) {
    last(this.getCondition(), last, c) and c instanceof SimpleCompletion
    or
    last(this.getBody(), last, c) and c instanceof BreakCompletion
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    // Body normal → condition
    last(this.getBody(), pred, c) and
    completionIsNormal(c) and
    first(this.getCondition(), succ)
    or
    // Body continue → condition
    last(this.getBody(), pred, c) and
    c instanceof ContinueCompletion and
    first(this.getCondition(), succ)
    or
    // Condition → body (loop back)
    last(this.getCondition(), pred, c) and
    c instanceof SimpleCompletion and
    first(this.getBody(), succ)
  }
}

/**
 * For statement:
 *   init → condition → body → update → condition (loop)
 *   condition simple → exit
 *   break → exit
 */
private class ForStatementTree extends ControlFlowTree instanceof Php::ForStatement {
  private Php::AstNode getInit() { result = this.(Php::ForStatement).getInitialize() }

  private Php::AstNode getCondition() { result = this.(Php::ForStatement).getCondition() }

  private Php::AstNode getUpdate() { result = this.(Php::ForStatement).getUpdate() }

  private Php::AstNode getBody() { result = this.(Php::ForStatement).getBody(0) }

  override predicate propagatesAbnormal(Php::AstNode child) {
    child = this.getInit() or child = this.getCondition()
  }

  override predicate first(Php::AstNode first) {
    first(this.getInit(), first)
    or
    not exists(this.getInit()) and first(this.getCondition(), first)
    or
    not exists(this.getInit()) and not exists(this.getCondition()) and
    first(this.getBody(), first)
    or
    not exists(this.getInit()) and not exists(this.getCondition()) and
    not exists(this.getBody()) and first = this
  }

  override predicate last(Php::AstNode last, Completion c) {
    // Exit via condition
    exists(this.getCondition()) and last(this.getCondition(), last, c) and
    c instanceof SimpleCompletion
    or
    // Exit via break
    last(this.getBody(), last, c) and c instanceof BreakCompletion
    or
    // Infinite loop with no condition: only break exits
    not exists(this.getCondition()) and last = this and c instanceof SimpleCompletion
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    // Init → condition
    exists(this.getCondition()) and
    last(this.getInit(), pred, c) and completionIsNormal(c) and
    first(this.getCondition(), succ)
    or
    // Init → body (no condition)
    not exists(this.getCondition()) and exists(this.getBody()) and
    last(this.getInit(), pred, c) and completionIsNormal(c) and
    first(this.getBody(), succ)
    or
    // Condition → body
    exists(this.getBody()) and
    last(this.getCondition(), pred, c) and c instanceof SimpleCompletion and
    first(this.getBody(), succ)
    or
    // Body normal → update (if exists)
    exists(this.getUpdate()) and
    last(this.getBody(), pred, c) and completionIsNormal(c) and
    first(this.getUpdate(), succ)
    or
    // Body normal → condition (no update)
    not exists(this.getUpdate()) and exists(this.getCondition()) and
    last(this.getBody(), pred, c) and completionIsNormal(c) and
    first(this.getCondition(), succ)
    or
    // Body normal → body (no update, no condition — infinite loop)
    not exists(this.getUpdate()) and not exists(this.getCondition()) and
    last(this.getBody(), pred, c) and completionIsNormal(c) and
    first(this.getBody(), succ)
    or
    // Update → condition (loop back)
    exists(this.getCondition()) and
    last(this.getUpdate(), pred, c) and completionIsNormal(c) and
    first(this.getCondition(), succ)
    or
    // Update → body (no condition)
    not exists(this.getCondition()) and exists(this.getBody()) and
    last(this.getUpdate(), pred, c) and completionIsNormal(c) and
    first(this.getBody(), succ)
    or
    // Continue → update (or condition if no update)
    exists(this.getUpdate()) and
    last(this.getBody(), pred, c) and c instanceof ContinueCompletion and
    first(this.getUpdate(), succ)
    or
    not exists(this.getUpdate()) and exists(this.getCondition()) and
    last(this.getBody(), pred, c) and c instanceof ContinueCompletion and
    first(this.getCondition(), succ)
  }
}

/**
 * Foreach statement:
 *   iterable → body → iterable (loop)
 *   break → exit
 */
private class ForeachStatementTree extends ControlFlowTree instanceof Php::ForeachStatement {
  private Php::AstNode getBody() {
    result = this.(Php::ForeachStatement).getBody()
  }

  override predicate propagatesAbnormal(Php::AstNode child) { none() }

  override predicate first(Php::AstNode first) {
    first(this.getBody(), first)
    or
    not exists(this.getBody()) and first = this
  }

  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof SimpleCompletion
    or
    last(this.getBody(), last, c) and c instanceof BreakCompletion
  }

  override predicate succ(Php::AstNode pred, Php::AstNode succ, Completion c) {
    // Body → loop back
    last(this.getBody(), pred, c) and
    completionIsNormal(c) and
    first(this.getBody(), succ)
    or
    // Continue → loop back
    last(this.getBody(), pred, c) and
    c instanceof ContinueCompletion and
    first(this.getBody(), succ)
  }
}

// =============================================================================
// Switch statement
// =============================================================================

/** Switch statement: condition → cases sequentially. */
private class SwitchStatementTree extends StandardPreOrderTree instanceof Php::SwitchStatement {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::SwitchStatement).getCondition()
    or
    result = this.(Php::SwitchStatement).getBody() and i = 1
  }
}

/** Switch body: sequential case execution. */
private class SwitchBlockTree extends StandardPreOrderTree instanceof Php::SwitchBlock {
  override ControlFlowTree getChildNode(int i) {
    result = this.(Php::SwitchBlock).getChild(i)
  }
}

/** Case statement. */
private class CaseStatementTree extends StandardPreOrderTree instanceof Php::CaseStatement {
  override ControlFlowTree getChildNode(int i) {
    result = this.(Php::CaseStatement).getChild(i)
  }
}

/** Default statement. */
private class DefaultStatementTree extends StandardPreOrderTree instanceof Php::DefaultStatement {
  override ControlFlowTree getChildNode(int i) {
    result = this.(Php::DefaultStatement).getChild(i)
  }
}

// =============================================================================
// Try/catch/finally
// =============================================================================

/** Try statement: body → catch clauses → finally (simplified sequential model). */
private class TryStatementTree extends StandardPreOrderTree instanceof Php::TryStatement {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::TryStatement).getBody()
    or
    exists(int j | result = this.(Php::TryStatement).getChild(j) and i = j + 1)
  }
}

/** Catch clause: execute body. */
private class CatchClauseTree extends StandardPreOrderTree instanceof Php::CatchClause {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::CatchClause).getBody()
  }
}

/** Finally clause: execute body. */
private class FinallyClauseTree extends StandardPreOrderTree instanceof Php::FinallyClause {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::FinallyClause).getBody()
  }
}

// =============================================================================
// Expression trees (post-order: evaluate children first, then this node)
// =============================================================================

/** Throw expression: evaluate operand, then complete with ThrowCompletion. */
private class ThrowExpressionTree extends StandardPostOrderTree instanceof Php::ThrowExpression {
  override ControlFlowTree getChildNode(int i) {
    i = 0 and result = this.(Php::ThrowExpression).getChild()
  }

  override predicate last(Php::AstNode last, Completion c) {
    last = this and c instanceof ThrowCompletion
  }

  override predicate propagatesAbnormal(Php::AstNode child) { none() }
}

// =============================================================================
// Default trees for all other nodes
// =============================================================================

/**
 * Default tree for expression-like nodes not specifically handled.
 * Evaluates children left-to-right (post-order: children first, then this).
 */
private class DefaultExpressionTree extends StandardPostOrderTree instanceof Php::Expression {
  DefaultExpressionTree() {
    not this instanceof Php::ThrowExpression and
    not this instanceof Php::ArrowFunction and
    not this instanceof Php::AnonymousFunction and
    not this instanceof Php::Token
  }

  override ControlFlowTree getChildNode(int i) {
    result =
      rank[i + 1](ControlFlowTree child |
        isExecutableChild(this, child) and
        child instanceof ControlFlowTree
      |
        child
        order by
          child.getLocation().getStartLine(), child.getLocation().getStartColumn(),
          child.getLocation().getEndLine(), child.getLocation().getEndColumn()
      )
  }
}

/**
 * Default tree for statement-like nodes not specifically handled.
 * Executes children left-to-right (pre-order: this first, then children).
 */
private class DefaultStatementTree extends StandardPreOrderTree instanceof Php::Statement {
  DefaultStatementTree() {
    not this instanceof Php::CompoundStatement and
    not this instanceof Php::ExpressionStatement and
    not this instanceof Php::EchoStatement and
    not this instanceof Php::ReturnStatement and
    not this instanceof Php::BreakStatement and
    not this instanceof Php::ContinueStatement and
    not this instanceof Php::IfStatement and
    not this instanceof Php::ElseClause and
    not this instanceof Php::ElseIfClause and
    not this instanceof Php::WhileStatement and
    not this instanceof Php::DoStatement and
    not this instanceof Php::ForStatement and
    not this instanceof Php::ForeachStatement and
    not this instanceof Php::SwitchStatement and
    not this instanceof Php::SwitchBlock and
    not this instanceof Php::CaseStatement and
    not this instanceof Php::DefaultStatement and
    not this instanceof Php::TryStatement and
    not this instanceof Php::CatchClause and
    not this instanceof Php::FinallyClause and
    not this instanceof Php::FunctionDefinition and
    not this instanceof Php::Token
  }

  override ControlFlowTree getChildNode(int i) {
    result =
      rank[i + 1](ControlFlowTree child |
        isExecutableChild(this, child) and
        child instanceof ControlFlowTree
      |
        child
        order by
          child.getLocation().getStartLine(), child.getLocation().getStartColumn(),
          child.getLocation().getEndLine(), child.getLocation().getEndColumn()
      )
  }
}

/**
 * Default tree for non-expression, non-statement AST nodes that are also
 * not tokens. These are structural containers (like arguments, formal params,
 * class bodies, etc.).
 */
private class DefaultContainerTree extends StandardPreOrderTree instanceof Php::AstNode {
  DefaultContainerTree() {
    not this instanceof Php::Expression and
    not this instanceof Php::Statement and
    not this instanceof Php::Token and
    not this instanceof Php::Program and
    not this instanceof Php::FunctionDefinition and
    not this instanceof Php::MethodDeclaration and
    not this instanceof Php::AnonymousFunction and
    not this instanceof Php::ArrowFunction and
    not this instanceof Php::ElseClause and
    not this instanceof Php::ElseIfClause and
    not this instanceof Php::SwitchBlock and
    not this instanceof Php::CaseStatement and
    not this instanceof Php::DefaultStatement and
    not this instanceof Php::CatchClause and
    not this instanceof Php::FinallyClause
  }

  override ControlFlowTree getChildNode(int i) {
    result =
      rank[i + 1](ControlFlowTree child |
        isExecutableChild(this, child) and
        child instanceof ControlFlowTree
      |
        child
        order by
          child.getLocation().getStartLine(), child.getLocation().getStartColumn(),
          child.getLocation().getEndLine(), child.getLocation().getEndColumn()
      )
  }
}
