/**
 * @kind test
 */

import codeql.php.security.SqlInjectionQuery
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  SqlInjectionConfig::isSource(source) and
  SqlInjectionConfig::isSink(sink)
select sink, source
