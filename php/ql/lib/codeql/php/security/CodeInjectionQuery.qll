/**
 * Provides a taint-tracking configuration for detecting code injection vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import CodeInjectionCustomizations::CodeInjection

/**
 * A taint-tracking configuration for detecting code injection vulnerabilities.
 */
module CodeInjectionConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
