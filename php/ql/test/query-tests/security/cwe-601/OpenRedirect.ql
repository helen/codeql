/**
 * @kind test
 */

import codeql.php.security.OpenRedirectQuery
import codeql.php.DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  OpenRedirectConfig::isSource(source) and
  OpenRedirectConfig::isSink(sink)
select sink, source
