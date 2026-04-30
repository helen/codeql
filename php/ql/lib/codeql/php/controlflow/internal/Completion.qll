/**
 * Provides completion types for PHP control flow.
 *
 * A completion represents how the execution of a statement or expression
 * terminates: normally, by returning, throwing, breaking, or continuing.
 */
overlay[local]
module;

private import codeql.php.ast.internal.TreeSitter
import codeql.controlflow.SuccessorType

private newtype TCompletion =
  TSimpleCompletion() or
  TBooleanCompletion(boolean b) { b in [false, true] } or
  TReturnCompletion() or
  TBreakCompletion() or
  TContinueCompletion() or
  TThrowCompletion()

/** A completion: how a statement or expression terminates. */
abstract class Completion extends TCompletion {
  abstract string toString();

  /** Gets a successor type matching this completion. */
  abstract SuccessorType getAMatchingSuccessorType();

  /**
   * Holds if this completion is valid for AST node `n`.
   * A completion is valid for the node where it originates.
   */
  predicate isValidForSpecific(Php::AstNode n) { none() }

  predicate isValidFor(Php::AstNode n) {
    this.isValidForSpecific(n)
    or
    not any(Completion c).isValidForSpecific(n) and
    this instanceof SimpleCompletion
  }
}

/** A normal completion: flow continues to the next statement. */
abstract class NormalCompletion extends Completion { }

/** Simple normal completion (default for most nodes). */
class SimpleCompletion extends NormalCompletion, TSimpleCompletion {
  override string toString() { result = "simple" }

  override DirectSuccessor getAMatchingSuccessorType() { any() }
}

/** Boolean completion: the node evaluates to true or false. */
class BooleanCompletion extends NormalCompletion, TBooleanCompletion {
  boolean value;

  BooleanCompletion() { this = TBooleanCompletion(value) }

  override string toString() { result = "boolean(" + value + ")" }

  override BooleanSuccessor getAMatchingSuccessorType() { result.getValue() = value }

  /** Gets the boolean value of this completion. */
  boolean getValue() { result = value }
}

/** A true completion. */
class TrueCompletion extends BooleanCompletion {
  TrueCompletion() { this.getValue() = true }
}

/** A false completion. */
class FalseCompletion extends BooleanCompletion {
  FalseCompletion() { this.getValue() = false }
}

/** Return completion: a `return` statement was executed. */
class ReturnCompletion extends Completion, TReturnCompletion {
  override string toString() { result = "return" }

  override predicate isValidForSpecific(Php::AstNode n) { n instanceof Php::ReturnStatement }

  override ReturnSuccessor getAMatchingSuccessorType() { any() }
}

/** Break completion: a `break` statement was executed. */
class BreakCompletion extends Completion, TBreakCompletion {
  override string toString() { result = "break" }

  override predicate isValidForSpecific(Php::AstNode n) { n instanceof Php::BreakStatement }

  override BreakSuccessor getAMatchingSuccessorType() { any() }
}

/** Continue completion: a `continue` statement was executed. */
class ContinueCompletion extends Completion, TContinueCompletion {
  override string toString() { result = "continue" }

  override predicate isValidForSpecific(Php::AstNode n) { n instanceof Php::ContinueStatement }

  override ContinueSuccessor getAMatchingSuccessorType() { any() }
}

/** Throw completion: a `throw` expression was executed. */
class ThrowCompletion extends Completion, TThrowCompletion {
  override string toString() { result = "throw" }

  override predicate isValidForSpecific(Php::AstNode n) { n instanceof Php::ThrowExpression }

  override ExceptionSuccessor getAMatchingSuccessorType() { any() }
}
