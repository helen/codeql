/**
 * Provides default sources, sinks and sanitizers for detecting SQL injection
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting SQL injection
 * vulnerabilities, as well as extension points for adding your own.
 */
module SqlInjection {
  /** A data flow source for SQL injection vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for SQL injection vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for SQL injection vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource { }

  /** An SQL statement of a SQL execution, considered as a flow sink. */
  private class SqlExecutionAsSink extends Sink {
    SqlExecutionAsSink() { this = any(SqlExecution e).getSql() }
  }
}
