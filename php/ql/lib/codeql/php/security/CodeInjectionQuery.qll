/**
 * Provides a taint-tracking configuration for detecting code injection vulnerabilities.
 */

private import codeql.php.DataFlow
private import codeql.php.TaintTracking
import CodeInjectionCustomizations::CodeInjection

/**
 * A taint-tracking configuration for detecting code injection vulnerabilities.
 */
module CodeInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }
}

/** Taint-tracking for detecting code injection vulnerabilities. */
module CodeInjectionFlow = TaintTracking::Global<CodeInjectionConfig>;
