/** Provides classes representing basic blocks. */
overlay[local]
module;

private import codeql.php.ast.internal.TreeSitter
private import codeql.php.controlflow.internal.CfgImpl as CfgImpl
private import CfgImpl::BasicBlocks as BasicBlocksImpl
private import codeql.controlflow.BasicBlock as BB
private import codeql.Locations
import codeql.controlflow.SuccessorType

/** A control flow node. */
class CfgNode = CfgImpl::Node;

/**
 * A basic block, that is, a maximal straight-line sequence of control flow nodes
 * without branches or joins.
 */
final class BasicBlock extends BasicBlocksImpl::BasicBlock {
  /** Gets an immediate successor of this basic block, if any. */
  BasicBlock getASuccessor() { result = super.getASuccessor() }

  /** Gets an immediate successor of this basic block of a given type, if any. */
  BasicBlock getASuccessor(SuccessorType t) { result = super.getASuccessor(t) }

  /** Gets an immediate predecessor of this basic block, if any. */
  BasicBlock getAPredecessor() { result = super.getAPredecessor() }

  /** Gets the control flow node at a specific (zero-indexed) position in this basic block. */
  CfgNode getNode(int pos) { result = super.getNode(pos) }

  /** Gets a control flow node in this basic block. */
  CfgNode getANode() { result = super.getANode() }

  /** Gets the first control flow node in this basic block. */
  CfgNode getFirstNode() { result = super.getFirstNode() }

  /** Gets the last control flow node in this basic block. */
  CfgNode getLastNode() { result = super.getLastNode() }

  /** Gets the scope of this basic block. */
  CfgImpl::CfgScope::CfgScope getScope() { result = this.getFirstNode().getScope() }
}

/** An entry basic block. */
final class EntryBasicBlock extends BasicBlock {
  EntryBasicBlock() { this.getFirstNode() instanceof CfgImpl::EntryNode }
}

/** An exit basic block. */
final class ExitBasicBlock extends BasicBlock {
  ExitBasicBlock() { this.getLastNode() instanceof CfgImpl::ExitNode }
}

/** An annotated exit basic block. */
final class AnnotatedExitBasicBlock extends BasicBlock {
  private boolean normal;

  AnnotatedExitBasicBlock() {
    exists(CfgImpl::AnnotatedExitNode n |
      n = this.getANode() and
      if n.isNormal() then normal = true else normal = false
    )
  }

  /** Holds if this block represents a normal exit. */
  predicate isNormal() { normal = true }
}

/**
 * Module that implements `CfgSig` for use with the shared SSA library.
 */
module Cfg implements BB::CfgSig<Location> {
  class ControlFlowNode = CfgNode;

  class BasicBlock = BasicBlocksImpl::BasicBlock;

  class EntryBasicBlock = BasicBlocksImpl::EntryBasicBlock;

  predicate dominatingEdge(BasicBlock bb1, BasicBlock bb2) {
    BasicBlocksImpl::dominatingEdge(bb1, bb2)
  }
}
