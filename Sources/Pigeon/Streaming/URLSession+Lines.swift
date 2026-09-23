import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLSession {
  /// Streams a response body line by line.
  ///
  /// Lines are yielded without their terminator (`\n` or `\r\n`), and blank lines are kept so
  /// callers can detect Server-Sent Event boundaries. A final line without a terminator is
  /// still delivered. Responses with a status of 300 or above throw
  /// ``HTTPStreamError/unsuccessfulStatus(code:body:)`` once the body has been read.
  /// Cancelling iteration cancels the underlying request.
  public func lines(for request: URLRequest) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        do {
          let (bytes, response) = try await self.bytes(for: request)
          let status = (response as? HTTPURLResponse)?.statusCode ?? 200

          if status >= 300 {
            var body = Data()
            for try await byte in bytes { body.append(byte) }
            throw HTTPStreamError.unsuccessfulStatus(code: status, body: String(decoding: body, as: UTF8.self))
          }

          var buffer = Data()
          for try await byte in bytes {
            if byte == UInt8(ascii: "\n") {
              continuation.yield(Self.decodeLine(buffer))
              buffer.removeAll(keepingCapacity: true)
            } else {
              buffer.append(byte)
            }
          }
          if !buffer.isEmpty {
            continuation.yield(Self.decodeLine(buffer))
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  private static func decodeLine(_ data: Data) -> String {
    var line = String(decoding: data, as: UTF8.self)
    if line.hasSuffix("\r") { line.removeLast() }
    return line
  }
}
