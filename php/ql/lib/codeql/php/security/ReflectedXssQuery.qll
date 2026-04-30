/**
 * Provides a taint-tracking configuration for detecting reflected XSS vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import ReflectedXssCustomizations::ReflectedXss

/**
 * A taint-tracking configuration for detecting reflected XSS vulnerabilities.
 */
module ReflectedXssConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting reflected XSS vulnerabilities. */
module ReflectedXssFlow = TaintTracking::Global<ReflectedXssConfig>;
