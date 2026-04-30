/**
 * Provides modeling of PHP built-in functions as security sinks.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Concepts

/**
 * A call to `eval()`, modeled as code execution.
 */
private class EvalCall extends CodeExecution::Range {
  DataFlow::Node codeArg;

  EvalCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "eval" and
      codeArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getCode() { result = codeArg }
}

/**
 * A call to `assert()` with a string argument, modeled as code execution.
 */
private class AssertCall extends CodeExecution::Range {
  DataFlow::Node codeArg;

  AssertCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "assert" and
      codeArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getCode() { result = codeArg }
}

/**
 * A call to `exec()`, `system()`, `passthru()`, `shell_exec()`, or `popen()`,
 * modeled as system command execution.
 */
private class ShellExecCall extends SystemCommandExecution::Range {
  DataFlow::Node cmdArg;

  ShellExecCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = ["exec", "system", "passthru", "shell_exec", "popen"] and
      cmdArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getCommand() { result = cmdArg }
}

/**
 * A call to `proc_open()`, modeled as system command execution.
 */
private class ProcOpenCall extends SystemCommandExecution::Range {
  DataFlow::Node cmdArg;

  ProcOpenCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "proc_open" and
      cmdArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getCommand() { result = cmdArg }
}

/**
 * A call to `file_get_contents()`, `fopen()`, `readfile()`, `file()`, or `include`/`require`,
 * modeled as file system access.
 */
private class FileAccessCall extends FileSystemAccess::Range {
  DataFlow::Node pathArg;

  FileAccessCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() =
        ["file_get_contents", "fopen", "readfile", "file", "file_put_contents", "unlink", "mkdir",
          "rmdir", "copy", "rename"] and
      pathArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getAPathArgument() { result = pathArg }
}

/**
 * An `echo` statement or `print` expression in an HTML context, modeled as HTML construction.
 */
private class EchoAsHtmlSink extends HtmlConstruction::Range {
  DataFlow::Node contentArg;

  EchoAsHtmlSink() {
    exists(Php::EchoStatement echo |
      this = echo.getChild() and
      contentArg = this
    )
  }

  override DataFlow::Node getContent() { result = contentArg }
}

/**
 * A call to `mysql_query()` (legacy MySQL extension), modeled as SQL execution.
 */
private class LegacyMysqlQueryCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  LegacyMysqlQueryCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = ["mysql_query", "mysql_unbuffered_query"] and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}
