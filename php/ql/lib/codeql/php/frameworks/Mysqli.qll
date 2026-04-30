/**
 * Provides modeling of MySQLi functions and methods as SQL execution sinks.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Concepts

/**
 * A call to `mysqli_query()` or `mysqli::query()`, modeled as SQL execution.
 */
private class MysqliQueryCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  MysqliQueryCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "mysqli_query" and
      sqlArg = call.getArgumentValue(1)
    )
    or
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = "query" and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * A call to `mysqli_prepare()` or `mysqli::prepare()`, modeled as SQL execution.
 */
private class MysqliPrepareCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  MysqliPrepareCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "mysqli_prepare" and
      sqlArg = call.getArgumentValue(1)
    )
    or
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = "prepare" and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}
