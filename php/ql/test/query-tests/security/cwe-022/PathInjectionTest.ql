/**
 * @name Path injection test
 * @description Test path injection detection.
 * @kind problem
 * @id php/test/path-injection
 */

import codeql.php.security.PathInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  PathInjectionConfig::isSource(source) and
  PathInjectionConfig::isSink(sink)
select sink, "Path injection from $@.", source, "here"
