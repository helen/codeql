/**
 * Provides classes for working with the control flow graph.
 */

private import codeql.php.AST

/**
 * A control flow node.
 *
 * A control flow node represents a single point in the control flow of a program.
 */
class CfgNode extends AstNode {
  CfgNode() { any() }
}
