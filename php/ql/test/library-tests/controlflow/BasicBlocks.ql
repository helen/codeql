/**
 * @kind test
 */

import codeql.php.CFG
import codeql.php.controlflow.BasicBlocks

from BasicBlock bb
select bb, bb.length()
