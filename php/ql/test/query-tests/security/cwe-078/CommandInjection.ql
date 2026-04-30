/**
 * @kind test
 */

import codeql.php.security.CommandInjectionQuery
import codeql.php.DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  CommandInjectionConfig::isSource(source) and
  CommandInjectionConfig::isSink(sink)
select sink, source
