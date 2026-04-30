/**
 * Provides default sources, sinks and sanitizers for detecting unsafe deserialization
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting unsafe deserialization
 * vulnerabilities, as well as extension points for adding your own.
 */
module UnsafeDeserialization {
  /** A data flow source for deserialization vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for deserialization vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for deserialization vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource { }

  /** A deserialization call, considered as a flow sink. */
  private class DeserializationAsSink extends Sink {
    DeserializationAsSink() { this = any(Deserialization e).getData() }
  }
}
