/**
 * Provides a taint-tracking configuration for detecting open redirect vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import OpenRedirectCustomizations::OpenRedirect

/**
 * A taint-tracking configuration for detecting open redirect vulnerabilities.
 */
module OpenRedirectConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
