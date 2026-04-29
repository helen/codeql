/**
 * Provides public predicates for data flow.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter

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
}
