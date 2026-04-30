/**
 * Provides modeling of WordPress APIs as sources, sinks, and sanitizers.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Concepts
private import codeql.php.dataflow.RemoteFlowSources

/**
 * A call to WordPress database query functions:
 * `$wpdb->query()`, `$wpdb->get_results()`, `$wpdb->get_row()`, `$wpdb->get_var()`,
 * `$wpdb->get_col()`.
 */
private class WpdbQueryCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  WpdbQueryCall() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = ["query", "get_results", "get_row", "get_var", "get_col"] and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * A call to `$wpdb->prepare()`, modeled as SQL execution.
 * While `prepare()` is a sanitizer when used correctly, the first argument
 * is still a SQL template that should not contain user input.
 */
private class WpdbPrepareCall extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  WpdbPrepareCall() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() = "prepare" and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * WordPress functions that output HTML: `the_title()`, `the_content()`,
 * `the_excerpt()`, `bloginfo()`.
 * These echo their output and are thus HTML construction sinks if user data flows in.
 */
private class WpOutputFunction extends HtmlConstruction::Range {
  DataFlow::Node contentArg;

  WpOutputFunction() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = ["wp_die", "wp_send_json"] and
      contentArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getContent() { result = contentArg }
}

/**
 * A call to `wp_redirect()` or `wp_safe_redirect()`, modeled as a redirect sink.
 */
private class WpRedirectCall extends RedirectSink::Range {
  DataFlow::Node urlArg;

  WpRedirectCall() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = ["wp_redirect", "wp_safe_redirect"] and
      urlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getUrl() { result = urlArg }
}
