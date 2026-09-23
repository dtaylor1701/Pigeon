/// Incremental parser for `text/event-stream` bodies, fed one line at a time.
///
/// Follows the WHATWG event-stream rules: `:` lines are comments, one leading space after the
/// colon is stripped, a line without a colon is a field with an empty value, `retry:` and
/// unknown fields are ignored, and a blank line dispatches the buffered event.
public struct ServerSentEventParser: Sendable {
  private var eventName: String?
  private var eventID: String?
  private var dataLines: [String] = []

  public init() {}

  /// Consumes a line and returns an event if the line completed one.
  public mutating func consume(_ line: String) -> ServerSentEvent? {
    if line.isEmpty {
      return dispatch()
    }
    if line.hasPrefix(":") {
      return nil
    }

    let field: Substring
    var value: Substring
    if let colon = line.firstIndex(of: ":") {
      field = line[..<colon]
      value = line[line.index(after: colon)...]
      if value.hasPrefix(" ") { value = value.dropFirst() }
    } else {
      field = Substring(line)
      value = ""
    }

    switch field {
    case "event":
      eventName = String(value)
    case "data":
      dataLines.append(String(value))
    case "id":
      eventID = String(value)
    default:
      break
    }
    return nil
  }

  /// Dispatches any event still buffered when the stream ends.
  public mutating func finish() -> ServerSentEvent? {
    dispatch()
  }

  private mutating func dispatch() -> ServerSentEvent? {
    defer {
      eventName = nil
      dataLines.removeAll()
    }
    guard !dataLines.isEmpty else { return nil }
    return ServerSentEvent(event: eventName, data: dataLines.joined(separator: "\n"), id: eventID)
  }
}
