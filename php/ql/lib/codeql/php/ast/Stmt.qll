/**
 * Provides classes for working with PHP statements.
 */

private import codeql.php.ast.internal.TreeSitter

/** A statement. */
class Stmt extends Php::AstNode, @php_statement {
  override string getAPrimaryQlClass() { result = "Stmt" }
}

/** An expression statement. */
class ExprStmt extends Stmt, Php::ExpressionStatement {
  /** Gets the expression. */
  Php::AstNode getExpr() { result = Php::ExpressionStatement.super.getChild() }
}

/** An echo statement. */
class EchoStmt extends Stmt, Php::EchoStatement {
  /** Gets the expression. */
  Php::AstNode getExpr() { result = Php::EchoStatement.super.getChild() }
}

/** A return statement. */
class ReturnStmt extends Stmt, Php::ReturnStatement {
  /** Gets the return expression, if any. */
  Php::AstNode getExpr() { result = Php::ReturnStatement.super.getChild() }
}

/** An if statement. */
class IfStmt extends Stmt, Php::IfStatement {
  /** Gets the condition. */
  Php::AstNode getCondition() { result = Php::IfStatement.super.getCondition() }

  /** Gets the body. */
  Php::AstNode getBody() { result = Php::IfStatement.super.getBody() }

  /** Gets the `i`th alternative (elseif/else clause). */
  Php::AstNode getAlternative(int i) { result = Php::IfStatement.super.getAlternative(i) }
}

/** A while statement. */
class WhileStmt extends Stmt, Php::WhileStatement { }

/** A do-while statement. */
class DoWhileStmt extends Stmt, Php::DoStatement { }

/** A for statement. */
class ForStmt extends Stmt, Php::ForStatement { }

/** A foreach statement. */
class ForeachStmt extends Stmt, Php::ForeachStatement { }

/** A switch statement. */
class SwitchStmt extends Stmt, Php::SwitchStatement { }

/** A try statement. */
class TryStmt extends Stmt, Php::TryStatement { }

/** A throw expression used as a statement (via ExpressionStatement). */
class ThrowStmt extends ExprStmt {
  ThrowStmt() { this.getExpr() instanceof Php::ThrowExpression }
}

/** A break statement. */
class BreakStmt extends Stmt, Php::BreakStatement { }

/** A continue statement. */
class ContinueStmt extends Stmt, Php::ContinueStatement { }

/** A compound statement (block). */
class BlockStmt extends Stmt, Php::CompoundStatement { }
