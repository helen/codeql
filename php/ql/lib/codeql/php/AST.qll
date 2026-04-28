overlay[local]
module;

import codeql.Locations
import ast.Expr
import ast.Stmt
import ast.Literal
import ast.Variable
import ast.Call
import ast.Parameter
import ast.Declaration
import ast.Namespace
import ast.Type
import ast.Operation
private import ast.internal.AST
private import ast.internal.TreeSitter
private import Customizations
private import Diagnostics

/**
 * A node in the abstract syntax tree. This class is the base class for all PHP
 * program elements.
 */
class AstNode extends TAstNode {
  /**
   * Gets the name of a primary CodeQL class to which this node belongs.
   */
  string getAPrimaryQlClass() { result = "???" }

  /**
   * Gets a comma-separated list of the names of the primary CodeQL classes to
   * which this element belongs.
   */
  final string getPrimaryQlClasses() { result = concat(this.getAPrimaryQlClass(), ",") }

  /** Gets a textual representation of this node. */
  cached
  string toString() { none() }

  /** Gets the location of this node. */
  Location getLocation() { php_ast_node_location(this, result) }

  /** Gets the file of this node. */
  final File getFile() { result = this.getLocation().getFile() }

  /** Gets a child node of this `AstNode`. */
  final AstNode getAChild() { result = this.getAChild(_) }

  /** Gets the parent of this `AstNode`, if this node is not a root node. */
  final AstNode getParent() { result.getAChild() = this }

  /**
   * Gets a child of this node, which can also be retrieved using a predicate
   * named `pred`.
   */
  cached
  AstNode getAChild(string pred) { none() }
}

/** The synthetic root type for all PHP AST nodes. */
class TAstNode = @php_ast_node;

/** A PHP source file. */
class PhpFile extends File {
  PhpFile() {
    exists(Location loc |
      php_ast_node_location(_, loc) and
      this = loc.getFile()
    )
  }

  /** Gets a token in this file. */
  private Php::Token getAToken() { result.getLocation().getFile() = this }

  /** Gets the number of lines in this file. */
  int getNumberOfLines() { result = max([0, this.getAToken().getLocation().getEndLine()]) }
}

/**
 * A successfully extracted file, that is, a file that was extracted and
 * contains no extraction errors or warnings.
 */
class SuccessfullyExtractedFile extends File {
  SuccessfullyExtractedFile() {
    not exists(Diagnostic d |
      d.getLocation().getFile() = this and
      (
        d instanceof ExtractionError
        or
        d instanceof ExtractionWarning
      )
    )
  }
}
