/**
 * Provides a taint-tracking configuration for detecting path injection vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import PathInjectionCustomizations::PathInjection

/**
 * A taint-tracking configuration for detecting path injection vulnerabilities.
 */
module PathInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting path injection vulnerabilities. */
module PathInjectionFlow = TaintTracking::Global<PathInjectionConfig>;
