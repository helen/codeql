/**
 * @name SQL injection test
 * @description Test SQL injection detection.
 * @kind problem
 * @id php/test/sql-injection
 */

import codeql.php.security.SqlInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  SqlInjectionConfig::isSource(source) and
  SqlInjectionConfig::isSink(sink)
select sink, "SQL injection from $@.", source, "here"
