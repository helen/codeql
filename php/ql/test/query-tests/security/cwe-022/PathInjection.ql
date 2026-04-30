/**
 * @kind test
 */

import codeql.php.security.PathInjectionQuery
import codeql.php.DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  PathInjectionConfig::isSource(source) and
  PathInjectionConfig::isSink(sink)
select sink, source
