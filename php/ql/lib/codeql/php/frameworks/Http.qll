/**
 * Provides modeling of PHP's HTTP superglobals as remote flow sources.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * A PHP superglobal variable that contains remote user input.
 * This includes `$_GET`, `$_POST`, `$_REQUEST`, `$_COOKIE`, `$_SERVER`, and `$_FILES`.
 */
private class SuperglobalSource extends RemoteFlowSource::Range {
  string name;

  SuperglobalSource() {
    this instanceof Php::VariableName and
    name = this.(Php::VariableName).getChild().(Php::Name).getValue() and
    name = ["_GET", "_POST", "_REQUEST", "_COOKIE", "_SERVER", "_FILES"]
  }

  override string getSourceType() { result = "PHP superglobal $_" + name }
}

/**
 * An access to `php://input`, which contains raw POST data.
 */
private class PhpInputSource extends RemoteFlowSource::Range {
  PhpInputSource() {
    exists(Php::Token t |
      t = this and
      t.getValue().matches("%php://input%")
    )
  }

  override string getSourceType() { result = "php://input" }
}
