/**
 * @kind test
 */

import codeql.php.security.ReflectedXssQuery
import codeql.php.DataFlow

from DataFlow::Node source, DataFlow::Node sink
where
  ReflectedXssConfig::isSource(source) and
  ReflectedXssConfig::isSink(sink)
select sink, source
