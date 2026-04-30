/**
 * Provides PHP-specific taint tracking predicates.
 */
overlay[local]
module;


private import DataFlowPrivate
private import codeql.php.DataFlow
private import codeql.php.ast.internal.TreeSitter

/**
 * Holds if `node` should be a sanitizer in all global taint flow configurations
 * but not in local taint.
 */
predicate defaultTaintSanitizer(DataFlow::Node node) { none() }

/**
 * Holds if the additional step from `nodeFrom` to `nodeTo` should be included
 * in all global taint flow configurations.
 */
cached
predicate defaultAdditionalTaintStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo, string model) {
  model = "" and
  (
    // Array subscript: if the array is tainted, element access is tainted
    // e.g., $_GET["name"] is tainted if $_GET is tainted
    exists(Php::SubscriptExpression sub |
      nodeFrom = sub.getChild(0) and
      nodeTo = sub
    )
    or
    // Property access: if the object is tainted, property access is tainted
    // e.g., $obj->prop is tainted if $obj is tainted
    exists(Php::MemberAccessExpression mem |
      nodeFrom = mem.getObject() and
      nodeTo = mem
    )
    or
    // String concatenation (.): taint propagates from either operand
    exists(Php::BinaryExpression binop |
      binop.getOperator() = "." and
      (nodeFrom = binop.getLeft() or nodeFrom = binop.getRight()) and
      nodeTo = binop
    )
    or
    // Encapsed (interpolated) strings: taint propagates from interpolated parts
    exists(Php::EncapsedString enc |
      nodeFrom = enc.getChild(_) and
      nodeTo = enc
    )
    or
    // Heredoc with interpolation: taint propagates
    exists(Php::Heredoc hd |
      nodeFrom = hd.getValue().getChild(_) and
      nodeTo = hd
    )
  )
}

/**
 * Holds if taint flow configurations should allow implicit reads of `c` at sinks
 * and inputs to additional taint steps.
 */
bindingset[node]
predicate defaultImplicitTaintRead(DataFlow::Node node, DataFlow::ContentSet c) { none() }

/**
 * Holds if the additional step from `src` to `sink` should be considered in
 * speculative taint flow exploration.
 */
predicate speculativeTaintStep(DataFlow::Node src, DataFlow::Node sink) { none() }
