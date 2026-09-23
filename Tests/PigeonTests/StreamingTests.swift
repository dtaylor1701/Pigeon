import Foundation
import Testing
@testable import Pigeon

/// Serves canned responses to `URLSession` without touching the network.
final class StubURLProtocol: URLProtocol, @unchecked Sendable {
  nonisolated(unsafe) static var responses: [String: (status: Int, body: Data)] = [:]
  private static let lock = NSLock()

  static func stub(_ url: URL, status: Int, body: String) {
    lock.withLock { responses[url.absoluteString] = (status, Data(body.utf8)) }
  }

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    guard let url = request.url, let stub = Self.lock.withLock({ Self.responses[url.absoluteString] }) else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }
    let response = HTTPURLResponse(url: url, statusCode: stub.status, httpVersion: "HTTP/1.1", headerFields: nil)!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: stub.body)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}

  static func session() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: configuration)
  }
}

@Suite("Streaming")
struct StreamingTests {
  private func collect(_ stream: AsyncThrowingStream<String, Error>) async throws -> [String] {
    var lines: [String] = []
    for try await line in stream { lines.append(line) }
    return lines
  }

  @Test("Lines keep blanks, strip CRLF, and deliver an unterminated final line")
  func lines() async throws {
    let url = URL(string: "https://stub.test/lines")!
    StubURLProtocol.stub(url, status: 200, body: "data: a\r\n\r\ndata: b\nlast")
    let lines = try await collect(StubURLProtocol.session().lines(for: URLRequest(url: url)))
    #expect(lines == ["data: a", "", "data: b", "last"])
  }

  @Test("Unsuccessful status throws with the response body")
  func unsuccessfulStatus() async throws {
    let url = URL(string: "https://stub.test/limited")!
    StubURLProtocol.stub(url, status: 429, body: #"{"error":"slow down"}"#)
    await #expect(throws: HTTPStreamError.unsuccessfulStatus(code: 429, body: #"{"error":"slow down"}"#)) {
      _ = try await collect(StubURLProtocol.session().lines(for: URLRequest(url: url)))
    }
  }

  @Test("SSE parser handles comments, multi-line data, ids, bare fields, and trailing events")
  func parser() {
    var parser = ServerSentEventParser()
    let lines = [
      ": keep-alive", "retry: 1000", "event: update", "id: 7", "data: {\"a\":1}", "",
      "data:first", "data: second", "", "data", "", "data: trailing",
    ]
    var events: [ServerSentEvent] = []
    for line in lines {
      if let event = parser.consume(line) { events.append(event) }
    }
    if let event = parser.finish() { events.append(event) }

    #expect(events == [
      ServerSentEvent(event: "update", data: "{\"a\":1}", id: "7"),
      ServerSentEvent(data: "first\nsecond", id: "7"),
      ServerSentEvent(data: "", id: "7"),
      ServerSentEvent(data: "trailing", id: "7"),
    ])
  }

  @Test("Line streams group into events")
  func eventStream() async throws {
    let url = URL(string: "https://stub.test/events")!
    StubURLProtocol.stub(url, status: 200, body: "event: ping\ndata: 1\n\ndata: 2\n\n")
    var events: [ServerSentEvent] = []
    for try await event in StubURLProtocol.session().lines(for: URLRequest(url: url)).serverSentEvents() {
      events.append(event)
    }
    #expect(events == [ServerSentEvent(event: "ping", data: "1"), ServerSentEvent(data: "2")])
  }
}
