/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page
 *              allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @sub-severity high
 * @precision high
 * @id php/reflected-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

import codeql.php.AST
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.security.ReflectedXssQuery

from DataFlow::Node source, DataFlow::Node sink
where
  ReflectedXssConfig::isSource(source) and
  ReflectedXssConfig::isSink(sink)
select sink, "Cross-site scripting vulnerability due to a $@.", source, "user-provided value"
