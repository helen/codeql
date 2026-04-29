/**
 * Provides PHP-specific dataflow predicates needed by the shared dataflow library.
 */

private import codeql.util.Unit
private import codeql.dataflow.DataFlow
private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.Locations
private import DataFlowPublic

class DataFlowSecondLevelScope = Unit;

class DataFlowExpr = Php::AstNode;

/** A callable in PHP: function, method, anonymous function, arrow function, or program. */
class DataFlowCallable extends Php::AstNode {
  DataFlowCallable() {
    this instanceof Php::FunctionDefinition or
    this instanceof Php::MethodDeclaration or
    this instanceof Php::AnonymousFunction or
    this instanceof Php::ArrowFunction or
    this instanceof Php::Program
  }

  /** Gets the formal parameter list of this callable, if any. */
  Php::FormalParameters getParameterList() {
    result = this.(Php::FunctionDefinition).getParameters() or
    result = this.(Php::MethodDeclaration).getParameters() or
    result = this.(Php::AnonymousFunction).getParameters() or
    result = this.(Php::ArrowFunction).getParameters()
  }

  /** Gets the callable name for dispatch purposes. */
  string getCallableName() {
    result = this.(Php::FunctionDefinition).getName().getValue()
    or
    result = this.(Php::MethodDeclaration).getName().getValue()
  }
}

/** A call in PHP: function call, method call, nullsafe method call, or scoped call. */
class DataFlowCall extends Php::AstNode {
  DataFlowCall() {
    this instanceof Php::FunctionCallExpression or
    this instanceof Php::MemberCallExpression or
    this instanceof Php::NullsafeMemberCallExpression or
    this instanceof Php::ScopedCallExpression
  }

  DataFlowCallable getEnclosingCallable() { result = nodeGetEnclosingCallable(this) }

  /** Gets the arguments node. */
  Php::Arguments getCallArguments() {
    result = this.(Php::FunctionCallExpression).getArguments() or
    result = this.(Php::MemberCallExpression).getArguments() or
    result = this.(Php::NullsafeMemberCallExpression).getArguments() or
    result = this.(Php::ScopedCallExpression).getArguments()
  }

  /** Gets the called function name, for direct function calls only. */
  string getCalledFunctionName() {
    result = this.(Php::FunctionCallExpression).getFunction().(Php::Name).getValue()
  }
}

newtype TReturnKind = TNormalReturnKind()

abstract class ReturnKind extends TReturnKind {
  abstract string toString();
}

class NormalReturnKind extends ReturnKind, TNormalReturnKind {
  override string toString() { result = "return" }
}

/**
 * Gets the innermost enclosing callable for `node`.
 * Walks up the parent chain until a callable is found.
 * Callables are their own enclosing callable.
 */
DataFlowCallable nodeGetEnclosingCallable(Node node) {
  node instanceof DataFlowCallable and result = node
  or
  not node instanceof DataFlowCallable and
  result = getEnclosingCallableAncestor(node)
}

private DataFlowCallable getEnclosingCallableAncestor(Php::AstNode node) {
  node.getParent() instanceof DataFlowCallable and
  result = node.getParent()
  or
  not node.getParent() instanceof DataFlowCallable and
  result = getEnclosingCallableAncestor(node.getParent())
}

predicate isParameterNode(ParameterNode p, DataFlowCallable c, ParameterPosition pos) {
  exists(Php::FormalParameters fps |
    fps = c.getParameterList() and
    fps.getChild(pos) = p
  )
}

predicate isArgumentNode(ArgumentNode arg, DataFlowCall call, ArgumentPosition pos) {
  call.getCallArguments().getChild(pos) = arg
}

DataFlowType getNodeType(Node node) { any() }

predicate nodeIsHidden(Node node) { none() }

/** Gets the node corresponding to the expression `e`. */
Node exprNode(DataFlowExpr e) { result = e }

/**
 * Gets a viable implementation of the target of the given call.
 * For now, only handles direct function calls matched by name.
 */
DataFlowCallable viableCallable(DataFlowCall c) {
  exists(string name |
    name = c.getCalledFunctionName() and
    name = result.getCallableName() and
    result instanceof Php::FunctionDefinition
  )
}

OutNode getAnOutNode(DataFlowCall call, ReturnKind kind) {
  result = call and kind instanceof NormalReturnKind
}

// --- Types ---

private newtype TDataFlowType = TUnknownDataFlowType()

class DataFlowType extends TDataFlowType {
  string toString() { result = "" }
}

predicate compatibleTypes(DataFlowType t1, DataFlowType t2) { any() }

predicate typeStrongerThan(DataFlowType t1, DataFlowType t2) { none() }

// --- Content ---

private newtype TContent = TFieldContent(string name) { none() }

class Content extends TContent {
  string toString() { none() }
}

predicate forceHighPrecision(Content c) { none() }

class ContentApprox extends Content {
  string toString() { result = super.toString() }
}

ContentApprox getContentApprox(Content c) { result = c }

// --- Positions ---

class ParameterPosition extends int {
  ParameterPosition() { exists(Php::FormalParameters fps | exists(fps.getChild(this))) }
}

class ArgumentPosition extends int {
  ArgumentPosition() { exists(Php::Arguments args | exists(args.getChild(this))) }
}

predicate parameterMatch(ParameterPosition ppos, ArgumentPosition apos) { ppos = apos }

// --- Variable flow helpers ---

/**
 * Holds if `vn` is a VariableName that binds (writes) a variable, rather than reading it.
 * Covers: assignments, augmented assignments, reference assignments, parameters,
 * catch variables, static variable declarations, update expressions, property declarations,
 * global declarations, list destructuring, and closure use clauses.
 */
private predicate isVariableBinding(Php::VariableName vn) {
  exists(Php::AssignmentExpression a | a.getLeft() = vn) or
  exists(Php::AugmentedAssignmentExpression a | a.getLeft() = vn) or
  exists(Php::ReferenceAssignmentExpression a | a.getLeft() = vn) or
  exists(Php::SimpleParameter p | p.getName() = vn) or
  exists(Php::VariadicParameter p | p.getName() = vn) or
  exists(Php::CatchClause c | c.getName() = vn) or
  exists(Php::StaticVariableDeclaration s | s.getName() = vn) or
  exists(Php::UpdateExpression u | u.getArgument() = vn) or
  exists(Php::PropertyElement p | p.getName() = vn) or
  vn.getParent() instanceof Php::GlobalDeclaration or
  vn.getParent() instanceof Php::AnonymousFunctionUseClause or
  vn.getParent() instanceof Php::ListLiteral
}

/**
 * Holds if `vn` is a plain local variable read (not a binding/write occurrence).
 */
private predicate isVariableRead(Php::VariableName vn) {
  not isVariableBinding(vn) and
  // Exclude dynamic variable names ($$x) and property declarations
  not vn.getParent() instanceof Php::DynamicVariableName
}

/**
 * Holds if `write` is a write of variable named `name` in callable `c`, at line `line`.
 */
private predicate variableWrite(
  Php::AstNode write, string name, DataFlowCallable c, int line
) {
  exists(Php::VariableName lhs |
    (
      exists(Php::AssignmentExpression a | a.getLeft() = lhs and write = a)
      or
      exists(Php::AugmentedAssignmentExpression a | a.getLeft() = lhs and write = a)
      or
      exists(Php::ReferenceAssignmentExpression a | a.getLeft() = lhs and write = a)
    ) and
    name = lhs.getChild().getValue() and
    c = nodeGetEnclosingCallable(write) and
    line = write.getLocation().getStartLine()
  )
  or
  exists(Php::SimpleParameter p |
    write = p and
    name = p.getName().getChild().getValue() and
    c = nodeGetEnclosingCallable(p) and
    line = p.getLocation().getStartLine()
  )
}

/**
 * Holds if `read` is a read of variable named `name` in callable `c`, at line `line`.
 */
private predicate variableReadAt(
  Php::VariableName read, string name, DataFlowCallable c, int line
) {
  isVariableRead(read) and
  name = read.getChild().getValue() and
  c = nodeGetEnclosingCallable(read) and
  line = read.getLocation().getStartLine()
}

// --- Flow steps ---

/**
 * Holds if there is a simple local flow step from `node1` to `node2`.
 * These are value-preserving intra-callable flow steps.
 */
cached
predicate simpleLocalFlowStep(Node node1, Node node2, string model) {
  model = "" and
  (
    // Assignment: RHS value flows to the assignment expression
    exists(Php::AssignmentExpression assign |
      node1 = assign.getRight() and
      node2 = assign
    )
    or
    // Reference assignment: RHS value flows to the assignment expression
    exists(Php::ReferenceAssignmentExpression assign |
      node1 = assign.getRight() and
      node2 = assign
    )
    or
    // Augmented assignment: RHS value flows to the assignment expression
    exists(Php::AugmentedAssignmentExpression assign |
      node1 = assign.getRight() and
      node2 = assign
    )
    or
    // Parenthesized expression: inner flows to outer
    exists(Php::ParenthesizedExpression paren |
      node1 = paren.getChild() and
      node2 = paren
    )
    or
    // Return statement: return expression flows to the return node
    exists(Php::ReturnStatement ret |
      node1 = ret.getChild() and
      node2 = ret
    )
    or
    // Argument wrapper: value inside an Argument node flows to the Argument
    exists(Php::Argument arg |
      node1 = arg.getChild() and
      node2 = arg
    )
    or
    // Expression statement: expression flows to the statement
    exists(Php::ExpressionStatement exprStmt |
      node1 = exprStmt.getChild() and
      node2 = exprStmt
    )
    or
    // Arrow function body: the body expression is the implicit return value
    exists(Php::ArrowFunction arrow |
      node1 = arrow.getBody() and
      node2 = arrow
    )
    or
    // Variable flow: a write of $x flows to subsequent reads of $x in the same callable.
    // Over-approximates without SSA/CFG (all writes to all later reads), but sound for security analysis.
    exists(string name, DataFlowCallable c, int writeLine, int readLine |
      variableWrite(node1, name, c, writeLine) and
      variableReadAt(node2, name, c, readLine) and
      writeLine <= readLine
    )
  )
}

predicate jumpStep(Node node1, Node node2) { none() }

predicate readStep(Node node1, ContentSet c, Node node2) { none() }

predicate storeStep(Node node1, ContentSet c, Node node2) { none() }

predicate clearsContent(Node n, ContentSet c) { none() }

predicate expectsContent(Node n, ContentSet c) { none() }

// --- Regions ---

class NodeRegion instanceof Unit {
  string toString() { result = "NodeRegion" }

  predicate contains(Node n) { none() }
}

predicate isUnreachableInCall(NodeRegion nr, DataFlowCall call) { none() }

// --- Self-return ---

predicate allowParameterReturnInSelf(ParameterNode p) { none() }

predicate localMustFlowStep(Node node1, Node node2) {
  simpleLocalFlowStep(node1, node2, _)
}

// --- Lambdas ---

private newtype TLambdaCallKind = TNoLambdaCallKind()

class LambdaCallKind = TLambdaCallKind;

predicate lambdaCreation(Node creation, LambdaCallKind kind, DataFlowCallable c) { none() }

predicate lambdaCall(DataFlowCall call, LambdaCallKind kind, Node receiver) { none() }

predicate additionalLambdaFlowStep(Node nodeFrom, Node nodeTo, boolean preservesValue) { none() }

// --- Source/Sink models ---

predicate knownSourceModel(Node source, string model) { none() }

predicate knownSinkModel(Node sink, string model) { none() }

/**
 * Since PHP dataflow doesn't use SSA or CFG compression, show all nodes in path graphs.
 */
predicate neverSkipInPathGraph(Node node) { any() }
