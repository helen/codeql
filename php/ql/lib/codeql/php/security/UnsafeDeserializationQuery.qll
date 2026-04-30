/**
 * Provides a taint-tracking configuration for detecting unsafe deserialization vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import UnsafeDeserializationCustomizations::UnsafeDeserialization

/**
 * A taint-tracking configuration for detecting unsafe deserialization vulnerabilities.
 */
module UnsafeDeserializationConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting unsafe deserialization vulnerabilities. */
module UnsafeDeserializationFlow = TaintTracking::Global<UnsafeDeserializationConfig>;
