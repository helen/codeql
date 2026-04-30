/**
 * Provides classes for working with PHP namespaces and use declarations.
 */
overlay[local]
module;


private import codeql.php.ast.internal.TreeSitter

/** A namespace definition. */
class NamespaceDef extends Php::NamespaceDefinition { }

/** A namespace use declaration. */
class UseDecl extends Php::NamespaceUseDeclaration { }
