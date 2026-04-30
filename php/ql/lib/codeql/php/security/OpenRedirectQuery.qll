/**
 * Provides a taint-tracking configuration for detecting open redirect vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import OpenRedirectCustomizations::OpenRedirect

/**
 * A taint-tracking configuration for detecting open redirect vulnerabilities.
 */
module OpenRedirectConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting open redirect vulnerabilities. */
module OpenRedirectFlow = TaintTracking::Global<OpenRedirectConfig>;
