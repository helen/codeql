/**
 * Provides a taint-tracking configuration for detecting reflected XSS vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import ReflectedXssCustomizations::ReflectedXss

/**
 * A taint-tracking configuration for detecting reflected XSS vulnerabilities.
 */
module ReflectedXssConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
