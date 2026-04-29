/**
 * Provides classes for working with PHP type annotations.
 */

private import codeql.php.ast.internal.TreeSitter

/** A type annotation. */
class TypeAnnotation extends Php::AstNode, @php_type__ {
  override string getAPrimaryQlClass() { result = "TypeAnnotation" }
}

/** A named type. */
class NamedTypeRef extends TypeAnnotation, Php::NamedType { }

/** A primitive type (int, string, bool, etc.). */
class PrimitiveTypeRef extends TypeAnnotation, Php::PrimitiveType { }

/** A union type (A|B). */
class UnionTypeRef extends TypeAnnotation, Php::UnionType { }

/** An intersection type (A&B). */
class IntersectionTypeRef extends TypeAnnotation, Php::IntersectionType { }

/** A nullable type (?A). */
class NullableTypeRef extends TypeAnnotation, Php::OptionalType { }
