/**
 * Provides classes for working with PHP literals.
 */
overlay[local]
module;


private import codeql.php.ast.internal.TreeSitter

/** A literal value. */
class Literal extends Php::AstNode, @php_literal {
}

/** An integer literal. */
class IntegerLiteral extends Literal, Php::Integer {
}

/** A float literal. */
class FloatLiteral extends Literal, Php::Float {
}

/** A string literal (single or double quoted). */
class StringLiteral extends Literal, @php_string__ {
}

/** A boolean literal (true or false). */
class BooleanLiteral extends Literal, Php::Boolean {
}

/** The null literal. */
class NullLiteral extends Literal, Php::Null {
}
