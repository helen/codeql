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

import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.security.OpenRedirectQuery

from DataFlow::Node source, DataFlow::Node sink
where
  OpenRedirectConfig::isSource(source) and
  OpenRedirectConfig::isSink(sink)
select sink, "This redirect URL depends on a $@.", source, "user-provided value"
