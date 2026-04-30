/**
 * Provides abstract classes representing generic concepts such as file system
 * access or system command execution, for which individual framework libraries
 * provide concrete subclasses.
 */

private import codeql.php.AST
private import codeql.php.CFG
private import codeql.php.dataflow.internal.DataFlowPublic as DataFlow
private import codeql.php.Frameworks
private import codeql.php.dataflow.RemoteFlowSources

/**
 * A data-flow node that executes SQL statements.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `SqlExecution::Range` instead.
 */
class SqlExecution extends DataFlow::Node instanceof SqlExecution::Range {
  /** Gets the argument that specifies the SQL statements to be executed. */
  DataFlow::Node getSql() { result = super.getSql() }
}

/** Provides a class for modeling new SQL execution APIs. */
module SqlExecution {
  /**
   * A data-flow node that executes SQL statements.
   *
   * Extend this class to model new APIs. If you want to refine existing API models,
   * extend `SqlExecution` instead.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the SQL statements to be executed. */
    abstract DataFlow::Node getSql();
  }
}

/**
 * A data-flow node that constructs HTML or writes to an HTTP response.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `HtmlConstruction::Range` instead.
 */
class HtmlConstruction extends DataFlow::Node instanceof HtmlConstruction::Range {
  /** Gets the argument that specifies the HTML content. */
  DataFlow::Node getContent() { result = super.getContent() }
}

/** Provides a class for modeling new HTML construction APIs. */
module HtmlConstruction {
  /**
   * A data-flow node that constructs HTML or writes to an HTTP response.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the HTML content. */
    abstract DataFlow::Node getContent();
  }
}

/**
 * A data-flow node that executes a system command.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `SystemCommandExecution::Range` instead.
 */
class SystemCommandExecution extends DataFlow::Node instanceof SystemCommandExecution::Range {
  /** Gets the argument that specifies the command to be executed. */
  DataFlow::Node getCommand() { result = super.getCommand() }
}

/** Provides a class for modeling new system command execution APIs. */
module SystemCommandExecution {
  /**
   * A data-flow node that executes a system command.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the command to be executed. */
    abstract DataFlow::Node getCommand();
  }
}

/**
 * A data-flow node that accesses the file system.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `FileSystemAccess::Range` instead.
 */
class FileSystemAccess extends DataFlow::Node instanceof FileSystemAccess::Range {
  /** Gets the argument that specifies the path to be accessed. */
  DataFlow::Node getAPathArgument() { result = super.getAPathArgument() }
}

/** Provides a class for modeling new file system access APIs. */
module FileSystemAccess {
  /**
   * A data-flow node that accesses the file system.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the path to be accessed. */
    abstract DataFlow::Node getAPathArgument();
  }
}

/**
 * A data-flow node that dynamically executes code.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `CodeExecution::Range` instead.
 */
class CodeExecution extends DataFlow::Node instanceof CodeExecution::Range {
  /** Gets the argument that specifies the code to be executed. */
  DataFlow::Node getCode() { result = super.getCode() }
}

/** Provides a class for modeling new code execution APIs. */
module CodeExecution {
  /**
   * A data-flow node that dynamically executes code.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the code to be executed. */
    abstract DataFlow::Node getCode();
  }
}

/**
 * A data-flow node that deserializes untrusted data.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `Deserialization::Range` instead.
 */
class Deserialization extends DataFlow::Node instanceof Deserialization::Range {
  /** Gets the argument that specifies the data to be deserialized. */
  DataFlow::Node getData() { result = super.getData() }
}

/** Provides a class for modeling new deserialization APIs. */
module Deserialization {
  /**
   * A data-flow node that deserializes untrusted data.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the data to be deserialized. */
    abstract DataFlow::Node getData();
  }
}

/**
 * A data-flow node that makes an outbound HTTP request (potential SSRF).
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `RequestForgery::Range` instead.
 */
class RequestForgery extends DataFlow::Node instanceof RequestForgery::Range {
  /** Gets the argument that specifies the URL of the request. */
  DataFlow::Node getUrl() { result = super.getUrl() }
}

/** Provides a class for modeling new request forgery APIs. */
module RequestForgery {
  /**
   * A data-flow node that makes an outbound HTTP request.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the URL of the request. */
    abstract DataFlow::Node getUrl();
  }
}

/**
 * A data-flow node that performs an HTTP redirect.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `RedirectSink::Range` instead.
 */
class RedirectSink extends DataFlow::Node instanceof RedirectSink::Range {
  /** Gets the argument that specifies the redirect URL. */
  DataFlow::Node getUrl() { result = super.getUrl() }
}

/** Provides a class for modeling new redirect APIs. */
module RedirectSink {
  /**
   * A data-flow node that performs an HTTP redirect.
   *
   * Extend this class to model new APIs.
   */
  abstract class Range extends DataFlow::Node {
    /** Gets the argument that specifies the redirect URL. */
    abstract DataFlow::Node getUrl();
  }
}
