/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access
 *              unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id php/path-injection
 * @tags security
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

import codeql.php.AST
import codeql.php.security.PathInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  PathInjectionConfig::isSource(source) and
  PathInjectionConfig::isSink(sink)
select sink, "This path depends on a $@.", source, "user-provided value"
