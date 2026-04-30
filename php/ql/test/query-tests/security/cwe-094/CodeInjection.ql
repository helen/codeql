/**
 * @kind test
 */

import codeql.php.security.CodeInjectionQuery
import codeql.php.DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  CodeInjectionConfig::isSource(source) and
  CodeInjectionConfig::isSink(sink)
select sink, source
