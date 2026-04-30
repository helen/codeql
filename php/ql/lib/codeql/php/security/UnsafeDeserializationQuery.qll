/**
 * Provides a taint-tracking configuration for detecting unsafe deserialization vulnerabilities.
 */

private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import UnsafeDeserializationCustomizations::UnsafeDeserialization

/**
 * A taint-tracking configuration for detecting unsafe deserialization vulnerabilities.
 */
module UnsafeDeserializationConfig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}
