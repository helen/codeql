/**
 * Internal AST helpers for PHP.
 */

private import codeql.php.ast.internal.TreeSitter

/** Gets the `Php::AstNode` that wraps the given raw `@php_ast_node`. */
Php::AstNode toPhpTreeSitterNode(@php_ast_node node) { result = node }
