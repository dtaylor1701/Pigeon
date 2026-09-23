/// A single dispatched Server-Sent Event.
public struct ServerSentEvent: Sendable, Equatable {
  /// The `event:` field, or `nil` for the default `message` type.
  public let event: String?
  /// The `data:` lines joined with newlines.
  public let data: String
  /// The `id:` field, if present.
  public let id: String?

  public init(event: String? = nil, data: String, id: String? = nil) {
    self.event = event
    self.data = data
    self.id = id
  }
}
