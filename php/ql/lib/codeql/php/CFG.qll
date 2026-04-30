/**
 * Provides the PHP control flow graph (CFG).
 *
 * The CFG is built from the AST using the shared controlflow library.
 * Each function, method, anonymous function, arrow function, and program
 * gets its own control flow graph.
 *
 * Import this module to access CFG nodes and edges:
 * ```ql
 * import codeql.php.CFG
 * ```
 */
overlay[local]
module;


import codeql.php.ast.internal.TreeSitter
private import codeql.php.controlflow.internal.CfgImpl as Impl

/** A control flow scope: a callable or program with its own CFG. */
class CfgScope = Impl::CfgScope::CfgScope;

