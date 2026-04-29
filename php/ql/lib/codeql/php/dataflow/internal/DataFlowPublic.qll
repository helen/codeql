/**
 * Provides public predicates for data flow.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import DataFlowPrivate

/**
 * A node in the data flow graph.
 */
class Node extends Php::AstNode {
  /** Gets a textual representation of this node. */
  override string toString() { result = super.toString() }
}

/** A data flow node corresponding to an expression. */
class ExprNode extends Node {
  ExprNode() { this instanceof @php_expression }
}

/** A data flow node corresponding to a parameter. */
class ParameterNode extends Node {
  ParameterNode() {
    this instanceof @php_simple_parameter or
    this instanceof @php_variadic_parameter
  }

  /** Holds if this parameter is at position `pos` in callable `c`. */
  predicate isParameterOf(DataFlowCallable c, ParameterPosition pos) {
    isParameterNode(this, c, pos)
  }
}

/** A data flow node corresponding to an argument in a call. */
class ArgumentNode extends Node {
  ArgumentNode() { exists(Php::Arguments args | args.getChild(_) = this) }

  /** Holds if this argument is at position `pos` in call `call`. */
  predicate argumentOf(DataFlowCall call, ArgumentPosition pos) {
    isArgumentNode(this, call, pos)
  }
}

/** A data flow node corresponding to a return statement. */
class ReturnNode extends Node {
  ReturnNode() { this instanceof Php::ReturnStatement }

  /** Gets the kind of this return node. */
  ReturnKind getKind() { result instanceof NormalReturnKind }
}

/**
 * A node that represents the output of a call.
 * The call expression itself evaluates to the return value.
 */
class OutNode extends Node {
  OutNode() {
    this instanceof Php::FunctionCallExpression or
    this instanceof Php::MemberCallExpression or
    this instanceof Php::NullsafeMemberCallExpression or
    this instanceof Php::ScopedCallExpression
  }
}

/**
 * A post-update node representing a value after a potential mutation.
 * Not yet implemented for PHP.
 */
class PostUpdateNode extends Node {
  PostUpdateNode() { none() }

  Node getPreUpdateNode() { none() }
}

/** A cast node. */
class CastNode extends Node {
  CastNode() { this instanceof Php::CastExpression }
}

/**
 * An entity that represents a set of `Content`s.
 */
class ContentSet instanceof Content {
  /** Gets a content that may be stored into when storing into this set. */
  Content getAStoreContent() { result = this }

  /** Gets a content that may be read from when reading from this set. */
  Content getAReadContent() { result = this }

  /** Gets a textual representation of this content set. */
  string toString() { result = super.toString() }
}
