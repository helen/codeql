/**
 * Provides default sources, sinks and sanitizers for detecting path injection
 * vulnerabilities, as well as extension points for adding your own.
 */

private import codeql.php.Concepts
private import codeql.php.ast.internal.TreeSitter
private import codeql.php.ast.Call
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.dataflow.RemoteFlowSources

/**
 * Provides default sources, sinks and sanitizers for detecting path injection
 * vulnerabilities, as well as extension points for adding your own.
 */
module PathInjection {
  /** A data flow source for path injection vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for path injection vulnerabilities. */
  abstract class Sink extends DataFlow::Node { }

  /** A sanitizer for path injection vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /** A source of remote user input, considered as a flow source. */
  private class RemoteFlowSourceAsSource extends Source, RemoteFlowSource { }

  /** A file system access path argument, considered as a flow sink. */
  private class FileSystemAccessAsSink extends Sink {
    FileSystemAccessAsSink() { this = any(FileSystemAccess e).getAPathArgument() }
  }

  /** A call to basename() or realpath() sanitizes path injection. */
  private class PathSanitizer extends Sanitizer {
    PathSanitizer() {
      exists(FunctionCall call |
        this = call and
        call.getFunctionName() = ["basename", "realpath"]
      )
    }
  }
}
