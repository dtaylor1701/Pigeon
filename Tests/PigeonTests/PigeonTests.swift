import Testing
import Foundation
@testable import Pigeon

@Suite("Pigeon Tests")
struct PigeonTests {
    let pigeon: Pigeon

    init() {
        pigeon = Pigeon(host: "pokeapi.co", relativePath: ["api", "v2"])
    }

    @Test func requestWithURL() async throws {
        let url = try #require(URL(string: "https://pokeapi.co/api/v2/pokemon/charmander"))
        _ = try await pigeon.request(.get,
                                             url: url,
                                             headers: [])
    }

    @Test func requestWithPath() async throws {
        _ = try await pigeon.request(.get,
                                             path: ["pokemon", "charmander"])
    }

    @Test func requestTypedResponse() async throws {
        pigeon.decoder.keyDecodingStrategy = .convertFromSnakeCase
        let charmander: Pokemon = try await pigeon.request(.get,
                                                            path: ["pokemon", "charmander"])
        #expect(charmander.name == "charmander")
    }

    @Test func postWithBodyData() async throws {
        let user = User(name: "Test user", job: "dog walker")
        let data = try JSONEncoder().encode(user)

        let pigeon = Pigeon(host: "httpbin.org")
        pigeon.userAgent = "PigeonTests"

        _ = try await pigeon.request(.post, path: "post", body: data)
    }

    @Test func postWithTypedBody() async throws {
        let user = User(name: "Test user", job: "dog walker")

        let pigeon = Pigeon(host: "httpbin.org")
        pigeon.userAgent = "PigeonTests"

        struct HttpBinResponse: Decodable {
            let json: User
        }

        let response: HttpBinResponse = try await pigeon.request(.post, path: "post", body: user)

        #expect(response.json.name == "Test user")
    }
}
