/**
 * @kind test
 */

import codeql.php.security.UnsafeDeserializationQuery
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  UnsafeDeserializationConfig::isSource(source) and
  UnsafeDeserializationConfig::isSink(sink)
select sink, source
