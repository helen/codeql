/**
 * Provides default sources, sinks and sanitizers for detecting open redirect
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting open redirect
 * vulnerabilities, as well as extension points for adding your own.
 */
module OpenRedirect {
  /** A data flow source for open redirect vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for open redirect vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for open redirect vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource { }

  /** A redirect URL, considered as a flow sink. */
  private class RedirectAsSink extends Sink {
    RedirectAsSink() { this = any(RedirectSink e).getUrl() }
  }
}
