extension AsyncThrowingStream where Element == String, Failure == Error {
  /// Groups a line stream (e.g. from `URLSession.lines(for:)`) into Server-Sent Events.
  public func serverSentEvents() -> AsyncThrowingStream<ServerSentEvent, Error> {
    AsyncThrowingStream<ServerSentEvent, Error> { continuation in
      let task = Task {
        var parser = ServerSentEventParser()
        do {
          for try await line in self {
            if let event = parser.consume(line) {
              continuation.yield(event)
            }
          }
          if let event = parser.finish() {
            continuation.yield(event)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }
}
