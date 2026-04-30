/**
 * Provides a taint-tracking configuration for detecting SSRF vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import SsrfCustomizations::Ssrf

/**
 * A taint-tracking configuration for detecting SSRF vulnerabilities.
 */
module SsrfConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting SSRF vulnerabilities. */
module SsrfFlow = TaintTracking::Global<SsrfConfig>;
