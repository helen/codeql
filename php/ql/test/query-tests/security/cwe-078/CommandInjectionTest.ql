/**
 * @name Command injection test
 * @description Test command injection detection.
 * @kind problem
 * @id php/test/command-injection
 */

import codeql.php.security.CommandInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  CommandInjectionConfig::isSource(source) and
  CommandInjectionConfig::isSink(sink)
select sink, "Command injection from $@.", source, "here"
