/**
 * Provides classes for working with PHP declarations (functions, classes, etc.).
 */

private import codeql.php.ast.internal.TreeSitter

/** A function definition. */
class FunctionDecl extends Php::FunctionDefinition {
  /** Gets the name of this function. */
  string getFunctionName() { result = this.getName().getNameString() }
}

/** A class declaration. */
class ClassDecl extends Php::ClassDeclaration {
  /** Gets the name of this class. */
  string getClassName() { result = this.getName().getNameString() }
}

/** An interface declaration. */
class InterfaceDecl extends Php::InterfaceDeclaration {
  /** Gets the name of this interface. */
  string getInterfaceName() { result = this.getName().getNameString() }
}

/** A trait declaration. */
class TraitDecl extends Php::TraitDeclaration {
  /** Gets the name of this trait. */
  string getTraitName() { result = this.getName().getNameString() }
}

/** An enum declaration. */
class EnumDecl extends Php::EnumDeclaration {
  /** Gets the name of this enum. */
  string getEnumName() { result = this.getName().getNameString() }
}

/** A method declaration. */
class MethodDecl extends Php::MethodDeclaration {
  /** Gets the name of this method. */
  string getMethodName() { result = this.getName().getNameString() }
}
