/**
 * Provides classes for working with PHP operations.
 */

private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Expr

/** A binary operation. */
class BinaryOp extends BinaryExpr { }

/** An addition expression. */
class AddExpr extends BinaryOp {
  AddExpr() { this.getOperator() = "+" }
}

/** A subtraction expression. */
class SubExpr extends BinaryOp {
  SubExpr() { this.getOperator() = "-" }
}

/** A multiplication expression. */
class MulExpr extends BinaryOp {
  MulExpr() { this.getOperator() = "*" }
}

/** A division expression. */
class DivExpr extends BinaryOp {
  DivExpr() { this.getOperator() = "/" }
}

/** A modulo expression. */
class ModExpr extends BinaryOp {
  ModExpr() { this.getOperator() = "%" }
}

/** A concatenation expression. */
class ConcatExpr extends BinaryOp {
  ConcatExpr() { this.getOperator() = "." }
}

/** An equality check expression. */
class EqExpr extends BinaryOp {
  EqExpr() { this.getOperator() = "==" }
}

/** An identity check expression. */
class IdenticalExpr extends BinaryOp {
  IdenticalExpr() { this.getOperator() = "===" }
}

/** A boolean AND expression. */
class LogicalAndExpr extends BinaryOp {
  LogicalAndExpr() { this.getOperator() = ["&&", "and"] }
}

/** A boolean OR expression. */
class LogicalOrExpr extends BinaryOp {
  LogicalOrExpr() { this.getOperator() = ["||", "or"] }
}

/** A null coalescing expression. */
class NullCoalesceExpr extends BinaryOp {
  NullCoalesceExpr() { this.getOperator() = "??" }
}
