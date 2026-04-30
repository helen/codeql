/**
 * Provides default sources, sinks and sanitizers for detecting reflected XSS
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting reflected XSS
 * vulnerabilities, as well as extension points for adding your own.
 */
module ReflectedXss {
  /** A data flow source for XSS vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for XSS vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for XSS vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource { }

  /** An HTML construction, considered as a flow sink. */
  private class HtmlConstructionAsSink extends Sink {
    HtmlConstructionAsSink() { this = any(HtmlConstruction e).getContent() }
  }

  /** A call to an HTML encoding function sanitizes XSS. */
  private class HtmlEncodingSanitizer extends Sanitizer {
    HtmlEncodingSanitizer() {
      exists(FunctionCall call |
        this = call and
        call.getFunctionName() =
          ["htmlspecialchars", "htmlentities", "strip_tags", "nl2br", "urlencode",
            "rawurlencode", "json_encode"]
      )
    }
  }

  /** A numeric cast sanitizes XSS. */
  private class NumericCastSanitizer extends Sanitizer {
    NumericCastSanitizer() {
      exists(Php::CastExpression cast |
        this = cast and
        cast.getType().(Php::Token).getValue() = ["(int)", "(integer)", "(float)", "(double)",
            "(bool)", "(boolean)"]
      )
      or
      exists(FunctionCall call |
        this = call and
        call.getFunctionName() = ["intval", "floatval", "doubleval"]
      )
    }
  }
}
