/**
 * Provides default sources, sinks and sanitizers for detecting SQL injection
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import SqlInjectionCustomizations::SqlInjection

/**
 * A taint-tracking configuration for detecting SQL injection vulnerabilities.
 */
module SqlInjectionConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
