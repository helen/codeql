/**
 * Provides a taint-tracking configuration for detecting path injection vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import PathInjectionCustomizations::PathInjection

/**
 * A taint-tracking configuration for detecting path injection vulnerabilities.
 */
module PathInjectionConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
