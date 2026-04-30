/**
 * Provides a taint-tracking configuration for detecting SSRF vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import SsrfCustomizations::Ssrf

/**
 * A taint-tracking configuration for detecting SSRF vulnerabilities.
 */
module SsrfConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
