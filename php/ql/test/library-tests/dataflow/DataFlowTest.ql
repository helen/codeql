/**
 * @name Dataflow test
 * @description Test dataflow through PHP code.
 * @kind table
 * @id php/test/dataflow
 */

import php
import codeql.php.dataflow.internal.DataFlowPublic as DataFlow

from DataFlow::Node node
where node instanceof DataFlow::ExprNode
select node, node.getAPrimaryQlClass()
