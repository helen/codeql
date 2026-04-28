/**
 * Provides a taint-tracking configuration for detecting command injection vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import CommandInjectionCustomizations::CommandInjection

/**
 * A taint-tracking configuration for detecting command injection vulnerabilities.
 */
module CommandInjectionConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
