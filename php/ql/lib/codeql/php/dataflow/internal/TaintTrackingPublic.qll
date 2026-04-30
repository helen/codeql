/**
 * Provides public taint-tracking predicates for PHP.
 */

private import codeql.php.DataFlow
private import DataFlowPrivate

private predicate localFlowStep(DataFlow::Node n1, DataFlow::Node n2) {
  simpleLocalFlowStep(n1, n2, _)
}

/**
 * Holds if there is local taint flow from `source` to `sink` in zero or more steps.
 */
predicate localTaint(DataFlow::Node source, DataFlow::Node sink) {
  source = sink or localFlowStep+(source, sink)
}
