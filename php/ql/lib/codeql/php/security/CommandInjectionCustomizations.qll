/**
 * Provides default sources, sinks and sanitizers for detecting command injection
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting command injection
 * vulnerabilities, as well as extension points for adding your own.
 */
module CommandInjection {
  /** A data flow source for command injection vulnerabilities. */
  abstract class Source extends DataFlow::Node {
    /** Gets a string that describes the type of this flow source. */
    string getSourceType() { result = "user-provided value" }
  }

  /** A data flow sink for command injection vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for command injection vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource {
    override string getSourceType() { result = RemoteFlowSource.super.getSourceType() }
  }

  /** A system command execution, considered as a flow sink. */
  private class SystemCommandExecutionAsSink extends Sink {
    SystemCommandExecutionAsSink() { this = any(SystemCommandExecution e).getCommand() }
  }
}
