/**
 * Provides modeling of PDO (PHP Data Objects) as SQL execution sinks.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Concepts

/**
 * A call to `PDO::query()` or `PDO::exec()`, modeled as SQL execution.
 */
private class PdoQueryCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  PdoQueryCall() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = ["query", "exec"] and
      sqlArg = call.getArgument(0).getValue()
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * A call to `PDO::prepare()`, modeled as SQL execution.
 */
private class PdoPrepareCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  PdoPrepareCall() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = "prepare" and
      sqlArg = call.getArgument(0).getValue()
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}
