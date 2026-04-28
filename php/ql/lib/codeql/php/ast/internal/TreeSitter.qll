/**
 * CodeQL library for PHP
 * Automatically generated from the tree-sitter grammar; do not edit
 */

import codeql.Locations as L

/** Holds if the database is an overlay. */
overlay[local]
private predicate isOverlay() { databaseMetadata("isOverlay", "true") }

/** Holds if `loc` is in the `file` and is part of the overlay base database. */
overlay[local]
private predicate discardableLocation(@file file, @location_default loc) {
  not isOverlay() and locations_default(loc, file, _, _, _, _)
}

/** Holds if `loc` should be discarded, because it is part of the overlay base and is in a file that was also extracted as part of the overlay database. */
overlay[discard_entity]
private predicate discardLocation(@location_default loc) {
  exists(@file file, string path | files(file, path) |
    discardableLocation(file, loc) and overlayChangedFiles(path)
  )
}

overlay[local]
module Php {
  /** The base class for all AST nodes */
  class AstNode extends @php_ast_node {
    /** Gets a string representation of this element. */
    string toString() { result = this.getAPrimaryQlClass() }

    /** Gets the location of this element. */
    final L::Location getLocation() { php_ast_node_location(this, result) }

    /** Gets the parent of this element. */
    final AstNode getParent() { php_ast_node_parent(this, result, _) }

    /** Gets the index of this node among the children of its parent. */
    final int getParentIndex() { php_ast_node_parent(this, _, result) }

    /** Gets a field or child node of this node. */
    AstNode getAFieldOrChild() { none() }

    /** Gets the name of the primary QL class for this element. */
    string getAPrimaryQlClass() { result = "???" }

    /** Gets a comma-separated list of the names of the primary CodeQL classes to which this element belongs. */
    string getPrimaryQlClasses() { result = concat(this.getAPrimaryQlClass(), ",") }
  }

  /** A token. */
  class Token extends @php_token, AstNode {
    /** Gets the value of this token. */
    final string getValue() { php_tokeninfo(this, _, result) }

    /** Gets a string representation of this element. */
    final override string toString() { result = this.getValue() }

    /** Gets the name of the primary QL class for this element. */
    override string getAPrimaryQlClass() { result = "Token" }
  }

  /** A reserved word. */
  class ReservedWord extends @php_reserved_word, Token {
    /** Gets the name of the primary QL class for this element. */
    final override string getAPrimaryQlClass() { result = "ReservedWord" }
  }

  /** Gets the file containing the given `node`. */
  private @file getNodeFile(@php_ast_node node) {
    exists(@location_default loc | php_ast_node_location(node, loc) |
      locations_default(loc, result, _, _, _, _)
    )
  }

  /** Holds if `node` is in the `file` and is part of the overlay base database. */
  private predicate discardableAstNode(@file file, @php_ast_node node) {
    not isOverlay() and file = getNodeFile(node)
  }

  /** Holds if `node` should be discarded. */
  overlay[discard_entity]
  private predicate discardAstNode(@php_ast_node node) {
    exists(@file file, string path | files(file, path) |
      discardableAstNode(file, node) and overlayChangedFiles(path)
    )
  }

  /** A program (top-level file). */
  class Program extends @php_program, AstNode {
    /** Gets the `i`th child. */
    final AstNode getChild(int i) { php_program_child(this, i, result) }

    /** Gets a child. */
    final AstNode getAChild() { php_program_child(this, _, result) }

    final override string getAPrimaryQlClass() { result = "Program" }

    final override AstNode getAFieldOrChild() { php_program_child(this, _, result) }
  }

  /** A compound statement (block). */
  class CompoundStatement extends @php_compound_statement, AstNode {
    /** Gets the `i`th child. */
    final AstNode getChild(int i) { php_compound_statement_child(this, i, result) }

    final override string getAPrimaryQlClass() { result = "CompoundStatement" }

    final override AstNode getAFieldOrChild() {
      php_compound_statement_child(this, _, result)
    }
  }

  /** An expression statement. */
  class ExpressionStatement extends @php_expression_statement, AstNode {
    /** Gets the expression. */
    final AstNode getExpression() { php_expression_statement_def(this, result) }

    final override string getAPrimaryQlClass() { result = "ExpressionStatement" }

    final override AstNode getAFieldOrChild() { result = this.getExpression() }
  }

  /** An echo statement. */
  class EchoStatement extends @php_echo_statement, AstNode {
    /** Gets the `i`th expression. */
    final AstNode getExpression(int i) { php_echo_statement_child(this, i, result) }

    final override string getAPrimaryQlClass() { result = "EchoStatement" }

    final override AstNode getAFieldOrChild() { php_echo_statement_child(this, _, result) }
  }

  /** A return statement. */
  class ReturnStatement extends @php_return_statement, AstNode {
    /** Gets the return expression, if any. */
    final AstNode getExpression() { php_return_statement_expression(this, result) }

    final override string getAPrimaryQlClass() { result = "ReturnStatement" }

    final override AstNode getAFieldOrChild() { result = this.getExpression() }
  }

  /** An if statement. */
  class IfStatement extends @php_if_statement, AstNode {
    /** Gets the condition. */
    final AstNode getCondition() { php_if_statement_def(this, result, _) }

    /** Gets the body. */
    final AstNode getBody() { php_if_statement_def(this, _, result) }

    /** Gets the `i`th alternative (elseif/else clause). */
    final AstNode getAlternative(int i) { php_if_statement_alternative(this, i, result) }

    final override string getAPrimaryQlClass() { result = "IfStatement" }

    final override AstNode getAFieldOrChild() {
      result = this.getCondition() or
      result = this.getBody() or
      php_if_statement_alternative(this, _, result)
    }
  }

  /** An else-if clause. */
  class ElseIfClause extends @php_else_if_clause, AstNode {
    final override string getAPrimaryQlClass() { result = "ElseIfClause" }
  }

  /** An else clause. */
  class ElseClause extends @php_else_clause, AstNode {
    final override string getAPrimaryQlClass() { result = "ElseClause" }
  }

  /** A while statement. */
  class WhileStatement extends @php_while_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "WhileStatement" }
  }

  /** A do-while statement. */
  class DoStatement extends @php_do_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "DoStatement" }
  }

  /** A for statement. */
  class ForStatement extends @php_for_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "ForStatement" }
  }

  /** A foreach statement. */
  class ForeachStatement extends @php_foreach_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "ForeachStatement" }
  }

  /** A switch statement. */
  class SwitchStatement extends @php_switch_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "SwitchStatement" }
  }

  /** A try statement. */
  class TryStatement extends @php_try_statement, AstNode {
    /** Gets the body. */
    final CompoundStatement getBody() { php_try_statement_def(this, result) }

    /** Gets the `i`th catch clause. */
    final CatchClause getCatch(int i) { php_try_statement_catch(this, i, result) }

    /** Gets the finally clause, if any. */
    final FinallyClause getFinally() { php_try_statement_finally(this, result) }

    final override string getAPrimaryQlClass() { result = "TryStatement" }
  }

  /** A catch clause. */
  class CatchClause extends @php_catch_clause, AstNode {
    final override string getAPrimaryQlClass() { result = "CatchClause" }
  }

  /** A finally clause. */
  class FinallyClause extends @php_finally_clause, AstNode {
    final override string getAPrimaryQlClass() { result = "FinallyClause" }
  }

  /** A throw statement. */
  class ThrowStatement extends @php_throw_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "ThrowStatement" }
  }

  /** A break statement. */
  class BreakStatement extends @php_break_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "BreakStatement" }
  }

  /** A continue statement. */
  class ContinueStatement extends @php_continue_statement, AstNode {
    final override string getAPrimaryQlClass() { result = "ContinueStatement" }
  }

  /** An assignment expression. */
  class AssignmentExpression extends @php_assignment_expression, AstNode {
    /** Gets the left-hand side. */
    final AstNode getLeft() { php_assignment_expression_def(this, result, _) }

    /** Gets the right-hand side. */
    final AstNode getRight() { php_assignment_expression_def(this, _, result) }

    final override string getAPrimaryQlClass() { result = "AssignmentExpression" }

    final override AstNode getAFieldOrChild() {
      result = this.getLeft() or result = this.getRight()
    }
  }

  /** An augmented assignment expression (e.g. `+=`, `.=`). */
  class AugmentedAssignmentExpression extends @php_augmented_assignment_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "AugmentedAssignmentExpression" }
  }

  /** A binary expression. */
  class BinaryExpression extends @php_binary_expression, AstNode {
    /** Gets the left operand. */
    final AstNode getLeft() { php_binary_expression_def(this, result, _, _) }

    /** Gets the operator. */
    final string getOperator() { php_binary_expression_def(this, _, result, _) }

    /** Gets the right operand. */
    final AstNode getRight() { php_binary_expression_def(this, _, _, result) }

    final override string getAPrimaryQlClass() { result = "BinaryExpression" }

    final override AstNode getAFieldOrChild() {
      result = this.getLeft() or result = this.getRight()
    }
  }

  /** A unary operation expression. */
  class UnaryOpExpression extends @php_unary_op_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "UnaryOpExpression" }
  }

  /** A conditional expression (ternary). */
  class ConditionalExpression extends @php_conditional_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "ConditionalExpression" }
  }

  /** A cast expression. */
  class CastExpression extends @php_cast_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "CastExpression" }
  }

  /** An instanceof expression. */
  class InstanceofExpression extends @php_instanceof_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "InstanceofExpression" }
  }

  /** A clone expression. */
  class CloneExpression extends @php_clone_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "CloneExpression" }
  }

  /** An include/require expression. */
  class IncludeExpression extends @php_include_expression, AstNode {
    /** Gets the kind (include, include_once, require, require_once). */
    final string getKind() { php_include_expression_def(this, result, _) }

    /** Gets the path expression. */
    final AstNode getPath() { php_include_expression_def(this, _, result) }

    final override string getAPrimaryQlClass() { result = "IncludeExpression" }
  }

  /** A function call expression. */
  class FunctionCallExpression extends @php_function_call_expression, AstNode {
    /** Gets the function being called. */
    final AstNode getFunction() { php_function_call_expression_def(this, result, _) }

    /** Gets the `i`th argument. */
    final Argument getArgument(int i) {
      php_function_call_expression_argument(this, i, result)
    }

    /** Gets an argument. */
    final Argument getAnArgument() {
      php_function_call_expression_argument(this, _, result)
    }

    final override string getAPrimaryQlClass() { result = "FunctionCallExpression" }

    final override AstNode getAFieldOrChild() {
      result = this.getFunction() or
      php_function_call_expression_argument(this, _, result)
    }
  }

  /** A method call expression. */
  class MemberCallExpression extends @php_member_call_expression, AstNode {
    /** Gets the object. */
    final AstNode getObject() { php_member_call_expression_def(this, result, _, _) }

    /** Gets the method name. */
    final AstNode getName() { php_member_call_expression_def(this, _, result, _) }

    /** Gets the `i`th argument. */
    final Argument getArgument(int i) {
      php_member_call_expression_argument(this, i, result)
    }

    /** Gets an argument. */
    final Argument getAnArgument() {
      php_member_call_expression_argument(this, _, result)
    }

    final override string getAPrimaryQlClass() { result = "MemberCallExpression" }

    final override AstNode getAFieldOrChild() {
      result = this.getObject() or
      result = this.getName() or
      php_member_call_expression_argument(this, _, result)
    }
  }

  /** A nullsafe method call expression. */
  class NullsafeMemberCallExpression extends @php_nullsafe_member_call_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "NullsafeMemberCallExpression" }
  }

  /** A scoped (static) call expression. */
  class ScopedCallExpression extends @php_scoped_call_expression, AstNode {
    /** Gets the scope. */
    final AstNode getScope() { php_scoped_call_expression_def(this, result, _) }

    /** Gets the method name. */
    final AstNode getName() { php_scoped_call_expression_def(this, _, result) }

    /** Gets the `i`th argument. */
    final Argument getArgument(int i) {
      php_scoped_call_expression_argument(this, i, result)
    }

    final override string getAPrimaryQlClass() { result = "ScopedCallExpression" }
  }

  /** An argument. */
  class Argument extends @php_argument, AstNode {
    /** Gets the value of this argument. */
    final AstNode getValue() { php_argument_def(this, result) }

    final override string getAPrimaryQlClass() { result = "Argument" }

    final override AstNode getAFieldOrChild() { result = this.getValue() }
  }

  /** A member access expression. */
  class MemberAccessExpression extends @php_member_access_expression, AstNode {
    /** Gets the object. */
    final AstNode getObject() { php_member_access_expression_def(this, result, _) }

    /** Gets the property name. */
    final AstNode getName() { php_member_access_expression_def(this, _, result) }

    final override string getAPrimaryQlClass() { result = "MemberAccessExpression" }
  }

  /** A subscript expression (array access). */
  class SubscriptExpression extends @php_subscript_expression, AstNode {
    /** Gets the object. */
    final AstNode getObject() { php_subscript_expression_def(this, result) }

    /** Gets the index, if any. */
    final AstNode getIndex() { php_subscript_expression_index(this, result) }

    final override string getAPrimaryQlClass() { result = "SubscriptExpression" }
  }

  /** A parenthesized expression. */
  class ParenthesizedExpression extends @php_parenthesized_expression, AstNode {
    /** Gets the wrapped expression. */
    final AstNode getExpression() { php_parenthesized_expression_def(this, result) }

    final override string getAPrimaryQlClass() { result = "ParenthesizedExpression" }
  }

  /** An encapsed (double-quoted) string. */
  class EncapsedString extends @php_encapsed_string, AstNode {
    final override string getAPrimaryQlClass() { result = "EncapsedString" }
  }

  /** A heredoc string. */
  class Heredoc extends @php_heredoc, AstNode {
    final override string getAPrimaryQlClass() { result = "Heredoc" }
  }

  /** An array creation expression. */
  class ArrayCreationExpression extends @php_array_creation_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "ArrayCreationExpression" }
  }

  /** A match expression. */
  class MatchExpression extends @php_match_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "MatchExpression" }
  }

  /** A yield expression. */
  class YieldExpression extends @php_yield_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "YieldExpression" }
  }

  /** A throw expression. */
  class ThrowExpression extends @php_throw_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "ThrowExpression" }
  }

  /** A print intrinsic. */
  class PrintIntrinsic extends @php_print_intrinsic, AstNode {
    final override string getAPrimaryQlClass() { result = "PrintIntrinsic" }
  }

  /** A shell command expression (backticks). */
  class ShellCommandExpression extends @php_shell_command_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "ShellCommandExpression" }
  }

  /** An object creation expression (new). */
  class ObjectCreationExpression extends @php_object_creation_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "ObjectCreationExpression" }
  }

  /** A silence expression (@). */
  class SilenceExpression extends @php_silence_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "SilenceExpression" }
  }

  /** An update expression (++/--). */
  class UpdateExpression extends @php_update_expression, AstNode {
    final override string getAPrimaryQlClass() { result = "UpdateExpression" }
  }

  /** A function definition. */
  class FunctionDefinition extends @php_function_definition, AstNode {
    /** Gets the name. */
    final Name getName() { php_function_definition_def(this, result, _, _) }

    /** Gets the parameters. */
    final FormalParameters getParameters() { php_function_definition_def(this, _, result, _) }

    /** Gets the body. */
    final CompoundStatement getBody() { php_function_definition_def(this, _, _, result) }

    /** Gets the return type, if any. */
    final AstNode getReturnType() { php_function_definition_return_type(this, result) }

    final override string getAPrimaryQlClass() { result = "FunctionDefinition" }

    final override AstNode getAFieldOrChild() {
      result = this.getName() or
      result = this.getParameters() or
      result = this.getBody()
    }
  }

  /** A class declaration. */
  class ClassDeclaration extends @php_class_declaration, AstNode {
    /** Gets the name. */
    final Name getName() { php_class_declaration_def(this, result, _) }

    /** Gets the body. */
    final AstNode getBody() { php_class_declaration_def(this, _, result) }

    final override string getAPrimaryQlClass() { result = "ClassDeclaration" }

    final override AstNode getAFieldOrChild() {
      result = this.getName() or result = this.getBody()
    }
  }

  /** An interface declaration. */
  class InterfaceDeclaration extends @php_interface_declaration, AstNode {
    /** Gets the name. */
    final Name getName() { php_interface_declaration_def(this, result, _) }

    final override string getAPrimaryQlClass() { result = "InterfaceDeclaration" }
  }

  /** A trait declaration. */
  class TraitDeclaration extends @php_trait_declaration, AstNode {
    /** Gets the name. */
    final Name getName() { php_trait_declaration_def(this, result, _) }

    final override string getAPrimaryQlClass() { result = "TraitDeclaration" }
  }

  /** An enum declaration. */
  class EnumDeclaration extends @php_enum_declaration, AstNode {
    /** Gets the name. */
    final Name getName() { php_enum_declaration_def(this, result, _) }

    final override string getAPrimaryQlClass() { result = "EnumDeclaration" }
  }

  /** A method declaration. */
  class MethodDeclaration extends @php_method_declaration, AstNode {
    /** Gets the name. */
    final Name getName() { php_method_declaration_def(this, result, _, _) }

    /** Gets the parameters. */
    final FormalParameters getParameters() { php_method_declaration_def(this, _, result, _) }

    /** Gets the body. */
    final AstNode getBody() { php_method_declaration_def(this, _, _, result) }

    /** Gets the return type, if any. */
    final AstNode getReturnType() { php_method_declaration_return_type(this, result) }

    final override string getAPrimaryQlClass() { result = "MethodDeclaration" }

    final override AstNode getAFieldOrChild() {
      result = this.getName() or
      result = this.getParameters() or
      result = this.getBody()
    }
  }

  /** A property declaration. */
  class PropertyDeclaration extends @php_property_declaration, AstNode {
    final override string getAPrimaryQlClass() { result = "PropertyDeclaration" }
  }

  /** A const declaration. */
  class ConstDeclaration extends @php_const_declaration, AstNode {
    final override string getAPrimaryQlClass() { result = "ConstDeclaration" }
  }

  /** An anonymous function (closure). */
  class AnonymousFunctionCreationExpression extends @php_anonymous_function_creation_expression,
    AstNode
  {
    final override string getAPrimaryQlClass() { result = "AnonymousFunctionCreationExpression" }
  }

  /** An arrow function. */
  class ArrowFunction extends @php_arrow_function, AstNode {
    final override string getAPrimaryQlClass() { result = "ArrowFunction" }
  }

  /** Formal parameters list. */
  class FormalParameters extends @php_formal_parameters, AstNode {
    /** Gets the `i`th parameter. */
    final AstNode getParameter(int i) { php_formal_parameters_child(this, i, result) }

    final override string getAPrimaryQlClass() { result = "FormalParameters" }

    final override AstNode getAFieldOrChild() {
      php_formal_parameters_child(this, _, result)
    }
  }

  /** A simple parameter. */
  class SimpleParameter extends @php_simple_parameter, AstNode {
    /** Gets the variable name. */
    final VariableName getVariableName() { php_simple_parameter_def(this, result) }

    /** Gets the type, if any. */
    final AstNode getType() { php_simple_parameter_type(this, result) }

    /** Gets the default value, if any. */
    final AstNode getDefault() { php_simple_parameter_default(this, result) }

    final override string getAPrimaryQlClass() { result = "SimpleParameter" }
  }

  /** A variadic parameter. */
  class VariadicParameter extends @php_variadic_parameter, AstNode {
    final override string getAPrimaryQlClass() { result = "VariadicParameter" }
  }

  /** A namespace definition. */
  class NamespaceDefinition extends @php_namespace_definition, AstNode {
    final override string getAPrimaryQlClass() { result = "NamespaceDefinition" }
  }

  /** A namespace use declaration. */
  class NamespaceUseDeclaration extends @php_namespace_use_declaration, AstNode {
    final override string getAPrimaryQlClass() { result = "NamespaceUseDeclaration" }
  }

  /** A name. */
  class Name extends @php_name, AstNode {
    /** Gets the name string. */
    final string getNameString() { php_name_def(this, result) }

    final override string toString() { result = this.getNameString() }

    final override string getAPrimaryQlClass() { result = "Name" }
  }

  /** A qualified name. */
  class QualifiedName extends @php_qualified_name, AstNode {
    final override string getAPrimaryQlClass() { result = "QualifiedName" }
  }

  /** A variable name. */
  class VariableName extends @php_variable_name, AstNode {
    /** Gets the name string (without the $ prefix). */
    final string getNameString() { php_variable_name_def(this, result) }

    final override string toString() { result = "$" + this.getNameString() }

    final override string getAPrimaryQlClass() { result = "VariableName" }
  }

  /** A namespace name. */
  class NamespaceName extends @php_namespace_name, AstNode {
    final override string getAPrimaryQlClass() { result = "NamespaceName" }
  }

  /** A named type. */
  class NamedType extends @php_named_type, AstNode {
    final override string getAPrimaryQlClass() { result = "NamedType" }
  }

  /** A primitive type. */
  class PrimitiveType extends @php_primitive_type, AstNode {
    final override string getAPrimaryQlClass() { result = "PrimitiveType" }
  }

  /** A union type. */
  class UnionType extends @php_union_type, AstNode {
    final override string getAPrimaryQlClass() { result = "UnionType" }
  }

  /** An intersection type. */
  class IntersectionType extends @php_intersection_type, AstNode {
    final override string getAPrimaryQlClass() { result = "IntersectionType" }
  }

  /** An optional (nullable) type. */
  class OptionalType extends @php_optional_type, AstNode {
    final override string getAPrimaryQlClass() { result = "OptionalType" }
  }

  /** An attribute. */
  class Attribute extends @php_attribute, AstNode {
    final override string getAPrimaryQlClass() { result = "Attribute" }
  }

  /** An attribute group. */
  class AttributeGroup extends @php_attribute_group, AstNode {
    final override string getAPrimaryQlClass() { result = "AttributeGroup" }
  }

  /** An attribute list. */
  class AttributeList extends @php_attribute_list, AstNode {
    final override string getAPrimaryQlClass() { result = "AttributeList" }
  }

  /** A text node (inline HTML). */
  class Text extends @php_text, AstNode {
    final override string getAPrimaryQlClass() { result = "Text" }
  }

  /** A text interpolation (PHP embedded in HTML). */
  class TextInterpolation extends @php_text_interpolation, AstNode {
    final override string getAPrimaryQlClass() { result = "TextInterpolation" }
  }

  /** A base clause (extends). */
  class BaseClause extends @php_base_clause, AstNode {
    final override string getAPrimaryQlClass() { result = "BaseClause" }
  }

  /** A class interface clause (implements). */
  class ClassInterfaceClause extends @php_class_interface_clause, AstNode {
    final override string getAPrimaryQlClass() { result = "ClassInterfaceClause" }
  }

  /** A declaration list (class body). */
  class DeclarationList extends @php_declaration_list, AstNode {
    final override string getAPrimaryQlClass() { result = "DeclarationList" }
  }
}
