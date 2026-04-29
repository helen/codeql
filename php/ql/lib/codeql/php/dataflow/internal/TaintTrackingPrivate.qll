/**
 * Provides PHP-specific taint tracking predicates.
 */

private import DataFlowPrivate
private import codeql.php.DataFlow

/**
 * Holds if `node` should be a sanitizer in all global taint flow configurations
 * but not in local taint.
 */
predicate defaultTaintSanitizer(DataFlow::Node node) { none() }

/**
 * Holds if the additional step from `nodeFrom` to `nodeTo` should be included
 * in all global taint flow configurations.
 */
cached
predicate defaultAdditionalTaintStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo, string model) {
  none()
}

/**
 * Holds if taint flow configurations should allow implicit reads of `c` at sinks
 * and inputs to additional taint steps.
 */
bindingset[node]
predicate defaultImplicitTaintRead(DataFlow::Node node, DataFlow::ContentSet c) { none() }

/**
 * Holds if the additional step from `src` to `sink` should be considered in
 * speculative taint flow exploration.
 */
predicate speculativeTaintStep(DataFlow::Node src, DataFlow::Node sink) { none() }
