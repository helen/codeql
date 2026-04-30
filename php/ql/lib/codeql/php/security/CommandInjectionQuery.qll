/**
 * Provides a taint-tracking configuration for detecting command injection vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import CommandInjectionCustomizations::CommandInjection

/**
 * A taint-tracking configuration for detecting command injection vulnerabilities.
 */
module CommandInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting command injection vulnerabilities. */
module CommandInjectionFlow = TaintTracking::Global<CommandInjectionConfig>;
