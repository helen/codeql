/**
 * Provides classes for working with PHP literals.
 */

private import codeql.php.ast.internal.TreeSitter

/** A literal value. */
class Literal extends Php::AstNode, @php_literal {
  override string getAPrimaryQlClass() { result = "Literal" }
}

/** An integer literal. */
class IntegerLiteral extends Literal, @php_token_integer {
  /** Gets the value of this literal as a string. */
  string getValue() { php_token_integer_def(this, result) }

  override string getAPrimaryQlClass() { result = "IntegerLiteral" }
}

/** A float literal. */
class FloatLiteral extends Literal, @php_token_float {
  /** Gets the value of this literal as a string. */
  string getValue() { php_token_float_def(this, result) }

  override string getAPrimaryQlClass() { result = "FloatLiteral" }
}

/** A string literal. */
class StringLiteral extends Literal, @php_token_string {
  /** Gets the value of this literal. */
  string getValue() { php_token_string_def(this, result) }

  override string getAPrimaryQlClass() { result = "StringLiteral" }
}

/** A boolean literal (true or false). */
class BooleanLiteral extends Literal, @php_token_boolean {
  override string getAPrimaryQlClass() { result = "BooleanLiteral" }
}

/** The null literal. */
class NullLiteral extends Literal, @php_token_null {
  override string getAPrimaryQlClass() { result = "NullLiteral" }
}
