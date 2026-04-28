/**
 * Provides classes for working with PHP expressions.
 */

private import codeql.php.ast.internal.TreeSitter

/** An expression. */
class Expr extends Php::AstNode, @php_underscore_expression {
  override string getAPrimaryQlClass() { result = "Expr" }
}

/** An assignment expression. */
class AssignExpr extends Expr, Php::AssignmentExpression { }

/** A binary expression. */
class BinaryExpr extends Expr, Php::BinaryExpression {
  /** Gets the left operand. */
  Expr getLeftOperand() { result = Php::BinaryExpression.super.getLeft() }

  /** Gets the right operand. */
  Expr getRightOperand() { result = Php::BinaryExpression.super.getRight() }

  /** Gets the operator as a string. */
  string getOperator() { result = Php::BinaryExpression.super.getOperator() }
}

/** A unary expression. */
class UnaryExpr extends Expr, Php::UnaryOpExpression { }

/** A conditional (ternary) expression. */
class ConditionalExpr extends Expr, Php::ConditionalExpression { }

/** A cast expression. */
class CastExpr extends Expr, Php::CastExpression { }

/** An instanceof expression. */
class InstanceofExpr extends Expr, Php::InstanceofExpression { }

/** A clone expression. */
class CloneExpr extends Expr, Php::CloneExpression { }

/** An include or require expression. */
class IncludeExpr extends Expr, Php::IncludeExpression {
  /** Gets the kind of include (include, include_once, require, require_once). */
  string getKind() { result = Php::IncludeExpression.super.getKind() }

  /** Gets the path expression. */
  Expr getPath() { result = Php::IncludeExpression.super.getPath() }
}

/** A parenthesized expression. */
class ParenExpr extends Expr, Php::ParenthesizedExpression {
  /** Gets the inner expression. */
  Expr getInnerExpr() { result = Php::ParenthesizedExpression.super.getExpression() }
}

/** An encapsed (interpolated) string. */
class EncapsedStringExpr extends Expr, Php::EncapsedString { }

/** A heredoc expression. */
class HeredocExpr extends Expr, Php::Heredoc { }

/** An array creation expression. */
class ArrayExpr extends Expr, Php::ArrayCreationExpression { }

/** A match expression. */
class MatchExpr extends Expr, Php::MatchExpression { }

/** A yield expression. */
class YieldExpr extends Expr, Php::YieldExpression { }

/** A throw expression. */
class ThrowExpr extends Expr, Php::ThrowExpression { }

/** A print expression. */
class PrintExpr extends Expr, Php::PrintIntrinsic { }

/** A shell command expression (backticks). */
class ShellExecExpr extends Expr, Php::ShellCommandExpression { }

/** A silence expression (@). */
class SilenceExpr extends Expr, Php::SilenceExpression { }

/** An object creation (new) expression. */
class NewExpr extends Expr, Php::ObjectCreationExpression { }

/** A subscript (array access) expression. */
class ArrayAccessExpr extends Expr, Php::SubscriptExpression {
  /** Gets the array being accessed. */
  Expr getArray() { result = Php::SubscriptExpression.super.getObject() }

  /** Gets the index expression. */
  Expr getIndex() { result = Php::SubscriptExpression.super.getIndex() }
}

/** A member access (property access) expression. */
class PropertyAccessExpr extends Expr, Php::MemberAccessExpression {
  /** Gets the object. */
  Expr getObject() { result = Php::MemberAccessExpression.super.getObject() }

  /** Gets the property name. */
  Php::AstNode getPropertyName() { result = Php::MemberAccessExpression.super.getName() }
}
