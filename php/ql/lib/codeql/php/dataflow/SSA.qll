/**
 * Provides the module `Ssa` for working with static single assignment (SSA) form.
 */

/**
 * Provides classes for working with static single assignment (SSA) form.
 */
module Ssa {
  private import codeql.php.controlflow.BasicBlocks
  private import codeql.php.dataflow.internal.SsaImpl as SsaImpl

  /** A PHP source variable (local variable identified by name and scope). */
  class SourceVariable = SsaImpl::PhpSourceVariable;

  /** A static single assignment (SSA) definition. */
  class Definition extends SsaImpl::Definition {
    /**
     * Gets the control flow node of this SSA definition, if any. Phi nodes and
     * parameter definitions are at index -1 in the basic block and have no CFG node.
     */
    CfgNode getControlFlowNode() {
      exists(BasicBlock bb, int i |
        this.definesAt(_, bb, i) and
        i >= 0 and
        result = bb.getNode(i)
      )
    }

    /**
     * Gets a control-flow node that reads the value of this SSA definition.
     */
    CfgNode getARead() { result = SsaImpl::getARead(this) }

    /** Gets the source variable underlying this SSA definition. */
    SourceVariable getSourceVariable() { this.definesAt(result, _, _) }

    /** Gets the basic block to which this SSA definition belongs. */
    BasicBlock getBasicBlock() { this.definesAt(_, result, _) }
  }

  /** A write definition (assignment, parameter, catch, foreach, etc.). */
  class WriteDefinition extends Definition, SsaImpl::WriteDefinition { }

  /** A phi definition at a control flow join. */
  class PhiDefinition extends Definition, SsaImpl::PhiNode { }
}
