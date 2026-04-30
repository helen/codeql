/**
 * Provides PHP-specific definitions for use in the data flow library.
 */

private import codeql.dataflow.DataFlow
private import codeql.Locations

module PhpDataFlow implements InputSig<Location> {
  import DataFlowPrivate as Private
  import DataFlowPublic
  import Private

  predicate neverSkipInPathGraph = Private::neverSkipInPathGraph/1;
}
