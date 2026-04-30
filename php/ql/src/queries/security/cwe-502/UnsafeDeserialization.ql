/**
 * @name Deserialization of user-controlled data
 * @description Deserializing user-controlled data may allow attackers to
 *              execute arbitrary code.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id php/unsafe-deserialization
 * @tags security
 *       external/cwe/cwe-502
 */

import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.security.UnsafeDeserializationQuery

from DataFlow::Node source, DataFlow::Node sink
where
  UnsafeDeserializationConfig::isSource(source) and
  UnsafeDeserializationConfig::isSink(sink)
select sink, "This deserialization depends on a $@.", source, "user-provided value"
