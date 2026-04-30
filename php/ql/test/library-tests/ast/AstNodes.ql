/**
 * @name AST node types
 * @description List all AST node types in the database.
 * @kind table
 * @id php/test/ast-node-types
 */

import php

from Ast::AstNode node
select node, node.getAPrimaryQlClass(), node.getLocation()
