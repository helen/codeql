/**
 * @kind test
 */

import codeql.php.ast.internal.TreeSitter

from Php::FunctionDefinition f
select f, f.getName().getValue()
