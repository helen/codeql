/**
 * Provides classes for working with PHP variables.
 */

private import codeql.php.ast.internal.TreeSitter

/** A variable name reference. */
class Variable extends Php::VariableName {
  /** Gets the name of this variable (without the $ prefix). */
  string getName() { result = this.getNameString() }
}

/** A dynamic variable name ($$var). */
class DynamicVariable extends Php::AstNode, @php_dynamic_variable_name {
  override string getAPrimaryQlClass() { result = "DynamicVariable" }
}
