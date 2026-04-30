/**
 * Provides modeling of Laravel framework features as sources and sinks.
 */

private import codeql.php.AST
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Concepts
private import codeql.php.dataflow.RemoteFlowSources

/**
 * A call to `$request->input()`, `$request->query()`, `$request->get()`,
 * `$request->post()`, or `$request->all()` on a Laravel Request object,
 * modeled as a remote flow source.
 */
private class LaravelRequestInput extends RemoteFlowSource::Range {
  LaravelRequestInput() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() =
        ["input", "query", "get", "post", "all", "only", "except", "header", "cookie", "file",
          "json", "getContent", "toArray"]
    )
  }

  override string getSourceType() { result = "Laravel request input" }
}

/**
 * A call to `request()` helper function, modeled as a remote flow source.
 */
private class LaravelRequestHelper extends RemoteFlowSource::Range {
  LaravelRequestHelper() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "request"
    )
  }

  override string getSourceType() { result = "Laravel request() helper" }
}

/**
 * A call to `DB::select()`, `DB::insert()`, `DB::update()`, `DB::delete()`,
 * `DB::statement()`, or `DB::raw()` — raw database operations in Laravel.
 */
private class LaravelDbRaw extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  LaravelDbRaw() {
    exists(StaticMethodCall call |
      this = call and
      call.getMethodNameString() = ["select", "insert", "update", "delete", "statement"] and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * A call to `DB::raw()`, which creates a raw SQL expression.
 */
private class LaravelDbRawExpr extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  LaravelDbRawExpr() {
    exists(StaticMethodCall call |
      this = call and
      call.getMethodNameString() = "raw" and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * A call to `->whereRaw()`, `->selectRaw()`, `->orderByRaw()`, `->groupByRaw()`,
 * `->havingRaw()` on a Laravel query builder.
 */
private class LaravelRawQueryBuilder extends SqlExecution::Range {
  DataFlow::Node sqlArg;

  LaravelRawQueryBuilder() {
    exists(MethodCall call |
      this = call and
      call.getMethodNameString() =
        ["whereRaw", "selectRaw", "orderByRaw", "groupByRaw", "havingRaw", "orWhereRaw"] and
      sqlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getSql() { result = sqlArg }
}

/**
 * A call to `response()` or `view()` returning HTML, modeled as HTML construction.
 */
private class LaravelResponseSink extends HtmlConstruction::Range {
  DataFlow::Node contentArg;

  LaravelResponseSink() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "response" and
      contentArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getContent() { result = contentArg }
}

/**
 * A call to `redirect()` helper or `Redirect::to()`, modeled as a redirect sink.
 */
private class LaravelRedirectSink extends RedirectSink::Range {
  DataFlow::Node urlArg;

  LaravelRedirectSink() {
    exists(FunctionCall call |
      this = call and
      call.getFunctionName() = "redirect" and
      urlArg = call.getArgumentValue(0)
    )
    or
    exists(StaticMethodCall call |
      this = call and
      call.getMethodNameString() = "to" and
      urlArg = call.getArgumentValue(0)
    )
  }

  override DataFlow::Node getUrl() { result = urlArg }
}
