/**
 * @name Server-side request forgery
 * @description Making HTTP requests with user-controlled URLs allows an attacker
 *              to access internal services or perform actions on behalf of the server.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id php/ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.security.SsrfQuery

from DataFlow::Node source, DataFlow::Node sink
where
  SsrfConfig::isSource(source) and
  SsrfConfig::isSink(sink)
select sink, "This request URL depends on a $@.", source, "user-provided value"
