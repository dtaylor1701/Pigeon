import Testing
import Foundation
@testable import Pigeon

@Suite("Service Tests")
struct ServiceTests {
    let service: Service

    init() {
        service = Service(host: "pokeapi.co", relativePath: ["api", "v2"])
    }

    @Test func requestWithURL() async throws {
        let url = try #require(URL(string: "https://pokeapi.co/api/v2/pokemon/charmander"))
        _ = try await service.request(.get,
                                             url: url,
                                             headers: [])
    }

    @Test func requestWithPath() async throws {
        _ = try await service.request(.get,
                                             path: ["pokemon", "charmander"])
    }

    @Test func requestTypedResponse() async throws {
        service.decoder.keyDecodingStrategy = .convertFromSnakeCase
        let charmander: Pokemon = try await service.request(.get,
                                                            path: ["pokemon", "charmander"])
        #expect(charmander.name == "charmander")
    }

    @Test func postWithBodyData() async throws {
        let user = User(name: "Test user", job: "dog walker")
        let data = try JSONEncoder().encode(user)

        let service = Service(host: "httpbin.org")
        service.userAgent = "PigeonTests"

        _ = try await service.request(.post, path: "post", body: data)
    }

    @Test func postWithTypedBody() async throws {
        let user = User(name: "Test user", job: "dog walker")

        let service = Service(host: "httpbin.org")
        service.userAgent = "PigeonTests"

        struct HttpBinResponse: Decodable {
            let json: User
        }

        let response: HttpBinResponse = try await service.request(.post, path: "post", body: user)

        #expect(response.json.name == "Test user")
    }
}
