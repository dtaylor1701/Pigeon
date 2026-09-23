import Foundation

/// Errors raised while streaming an HTTP response body.
public enum HTTPStreamError: LocalizedError, Equatable, Sendable {
  /// The server answered with a non-success status; `body` holds the full response text.
  case unsuccessfulStatus(code: Int, body: String)

  public var errorDescription: String? {
    switch self {
    case .unsuccessfulStatus(let code, let body):
      return body.isEmpty ? "HTTP \(code)" : "HTTP \(code): \(body)"
    }
  }
}
