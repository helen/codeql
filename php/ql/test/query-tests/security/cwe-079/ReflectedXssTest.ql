/**
 * @name XSS test
 * @description Test XSS detection.
 * @kind problem
 * @id php/test/reflected-xss
 */

import codeql.php.security.ReflectedXssQuery

from DataFlow::Node source, DataFlow::Node sink
where
  ReflectedXssConfig::isSource(source) and
  ReflectedXssConfig::isSink(sink)
select sink, "XSS from $@.", source, "here"
