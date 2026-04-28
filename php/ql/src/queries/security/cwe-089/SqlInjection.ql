/**
 * @name SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of
 *              malicious SQL code by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id php/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.security.SqlInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  SqlInjectionConfig::isSource(source) and
  SqlInjectionConfig::isSink(sink)
select sink, "This SQL query depends on a $@.", source, "user-provided value"
