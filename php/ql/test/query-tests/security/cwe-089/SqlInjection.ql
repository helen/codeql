/**
 * @kind test
 */

import codeql.php.security.SqlInjectionQuery
import codeql.php.DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  SqlInjectionConfig::isSource(source) and
  SqlInjectionConfig::isSink(sink)
select sink, source
