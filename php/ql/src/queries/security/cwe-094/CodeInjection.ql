/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id php/code-injection
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

import codeql.php.AST
import codeql.php.security.CodeInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  CodeInjectionConfig::isSource(source) and
  CodeInjectionConfig::isSink(sink)
select sink, "This code execution depends on a $@.", source, "user-provided value"
