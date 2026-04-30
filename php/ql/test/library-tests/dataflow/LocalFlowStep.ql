/**
 * @kind test
 */

import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
import codeql.php.dataflow.internal.DataFlowPrivate

from DataFlow::Node pred, DataFlow::Node succ
where simpleLocalFlowStep(pred, succ, _)
select pred, succ
