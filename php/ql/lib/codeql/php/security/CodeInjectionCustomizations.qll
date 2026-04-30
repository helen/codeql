/**
 * Provides default sources, sinks and sanitizers for detecting code injection
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting code injection
 * vulnerabilities, as well as extension points for adding your own.
 */
module CodeInjection {
  /** A data flow source for code injection vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for code injection vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for code injection vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource { }

  /** A code execution argument, considered as a flow sink. */
  private class CodeExecutionAsSink extends Sink {
    CodeExecutionAsSink() { this = any(CodeExecution e).getCode() }
  }

  /** A numeric cast or type coercion sanitizes code injection. */
  private class NumericSanitizer extends Sanitizer {
    NumericSanitizer() {
      exists(Php::CastExpression cast |
        this = cast and
        cast.getType().(Php::Token).getValue() = ["(int)", "(integer)", "(float)", "(double)",
            "(bool)", "(boolean)"]
      )
      or
      exists(FunctionCall call |
        this = call and
        call.getFunctionName() = ["intval", "floatval", "doubleval"]
      )
    }
  }
}
