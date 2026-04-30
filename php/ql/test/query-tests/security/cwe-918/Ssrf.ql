/**
 * @kind test
 */

import codeql.php.security.SsrfQuery
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  SsrfConfig::isSource(source) and
  SsrfConfig::isSink(sink)
select sink, source
