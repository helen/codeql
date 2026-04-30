/**
 * Provides classes for working with PHP parameters.
 */
overlay[local]
module;


private import codeql.php.ast.internal.TreeSitter

/** A parameter in a function or method definition. */
class Parameter extends Php::AstNode {
  Parameter() {
    this instanceof Php::SimpleParameter or
    this instanceof Php::VariadicParameter
  }

  /** Gets the name of this parameter. */
  string getParameterName() {
    this instanceof Php::SimpleParameter and
    result = this.(Php::SimpleParameter).getName().getChild().(Php::Name).getValue()
    or
    this instanceof Php::VariadicParameter and
    result = this.(Php::VariadicParameter).getName().getChild().(Php::Name).getValue()
  }

  /** Gets the type annotation, if any. */
  Php::AstNode getType() {
    result = this.(Php::SimpleParameter).getType()
    or
    result = this.(Php::VariadicParameter).getType()
  }

  /** Gets the default value, if any. */
  Php::AstNode getDefault() { result = this.(Php::SimpleParameter).getDefaultValue() }
}
