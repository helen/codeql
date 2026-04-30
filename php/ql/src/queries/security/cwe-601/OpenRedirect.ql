/**
 * @name URL redirect from remote source
 * @description Using user-controlled data in a URL redirect without validation
 *              allows an attacker to redirect users to malicious websites.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id php/open-redirect
 * @tags security
 *       external/cwe/cwe-601
 */

import codeql.php.DataFlow
import codeql.php.security.OpenRedirectQuery
import OpenRedirectFlow::PathGraph

from OpenRedirectFlow::PathNode source, OpenRedirectFlow::PathNode sink
where OpenRedirectFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This redirect URL depends on a $@.", source.getNode(),
  "user-provided value"
