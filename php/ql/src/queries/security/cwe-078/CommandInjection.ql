/**
 * @name Uncontrolled command line
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id php/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

import codeql.php.AST
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.security.CommandInjectionQuery

from DataFlow::Node source, DataFlow::Node sink
where
  CommandInjectionConfig::isSource(source) and
  CommandInjectionConfig::isSink(sink)
select sink, "This command depends on a $@.", source, "user-provided value"
