/**
 * Provides modeling of Symfony framework features as sources and sinks.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Concepts
private import codeql.php.dataflow.RemoteFlowSources

/**
 * A call to `getContent()`, `getQueryString()`, `getUri()`, or `getPathInfo()`
 * on a Symfony Request object, modeled as a remote flow source.
 */
private class SymfonyRequestInput extends RemoteFlowSource::Range {
  SymfonyRequestInput() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = ["getContent", "getQueryString", "getUri", "getPathInfo"]
    )
  }

  override string getSourceType() { result = "Symfony request input" }
}

/**
 * A Symfony `Response` constructor or `$response->setContent()` call.
 */
private class SymfonyResponseSink extends HtmlConstruction::Range {
  DataFlow::Node contentArg;

  SymfonyResponseSink() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = "setContent" and
      contentArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getContent() { result = contentArg }
}
