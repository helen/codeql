/**
 * Provides classes for working with PHP function and method calls.
 */
overlay[local]
module;


private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Expr

/** A call expression (function call, method call, or static call). */
class Call extends Expr {
  Call() {
    this instanceof Php::FunctionCallExpression or
    this instanceof Php::MemberCallExpression or
    this instanceof Php::NullsafeMemberCallExpression or
    this instanceof Php::ScopedCallExpression
  }

  /** Gets an argument of this call. */
  Php::Argument getAnArgument() {
    result = this.getArguments().(Php::Arguments).getChild(_)
  }

  /** Gets the `i`th argument of this call. */
  Php::Argument getArgument(int i) {
    result = this.getArguments().(Php::Arguments).getChild(i)
  }

  /** Gets the value expression of the `i`th argument. */
  Php::AstNode getArgumentValue(int i) {
    result = this.getArgument(i).getChild()
  }

  /** Gets the arguments node. */
  private Php::AstNode getArguments() {
    this instanceof Php::FunctionCallExpression and
    result = this.(Php::FunctionCallExpression).getArguments()
    or
    this instanceof Php::MemberCallExpression and
    result = this.(Php::MemberCallExpression).getArguments()
    or
    this instanceof Php::NullsafeMemberCallExpression and
    result = this.(Php::NullsafeMemberCallExpression).getArguments()
    or
    this instanceof Php::ScopedCallExpression and
    result = this.(Php::ScopedCallExpression).getArguments()
  }
}

/** A function call expression. */
class FunctionCall extends Call, Php::FunctionCallExpression {
  /** Gets the name of the called function, if it is a simple name. */
  string getFunctionName() {
    result = this.getFunction().(Php::Name).getValue()
    or
    result = this.getFunction().(Php::QualifiedName).getChild().getValue()
  }

  /** Gets the function name node. */
  Php::AstNode getFunctionNameNode() { result = this.getFunction() }
}

/** A method call expression (`$obj->method()`). */
class MethodCall extends Call, Php::MemberCallExpression {
  /** Gets the receiver object. */
  Expr getReceiver() { result = this.getObject() }

  /** Gets the method name. */
  Php::AstNode getMethodName() { result = this.getName() }

  /** Gets the method name as a string, if it is a simple name. */
  string getMethodNameString() { result = this.getName().(Php::Name).getValue() }
}

/** A static method call (`ClassName::method()`). */
class StaticMethodCall extends Call, Php::ScopedCallExpression {
  /** Gets the class scope. */
  Php::AstNode getClassScope() { result = this.getScope() }

  /** Gets the method name. */
  Php::AstNode getMethodName() { result = this.getName() }

  /** Gets the method name as a string, if it is a simple name. */
  string getMethodNameString() { result = this.getName().(Php::Name).getValue() }
}
