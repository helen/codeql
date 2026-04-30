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

import codeql.php.DataFlow
import codeql.php.security.SsrfQuery
import SsrfFlow::PathGraph

from SsrfFlow::PathNode source, SsrfFlow::PathNode sink
where SsrfFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This request URL depends on a $@.", source.getNode(),
  "user-provided value"
