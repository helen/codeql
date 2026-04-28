/**
 * @name Code injection test
 * @description Test code injection detection.
 * @kind problem
 * @id php/test/code-injection
 */

import codeql.php.security.CodeInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  CodeInjectionConfig::isSource(source) and
  CodeInjectionConfig::isSink(sink)
select sink, "Code injection from $@.", source, "here"
