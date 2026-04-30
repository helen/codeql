/**
 * @kind test
 */

import codeql.php.security.CommandInjectionQuery
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  CommandInjectionConfig::isSource(source) and
  CommandInjectionConfig::isSink(sink)
select sink, source
