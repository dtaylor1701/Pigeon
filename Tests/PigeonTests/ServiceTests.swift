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

        let reqresService = Service(host: "reqres.in", relativePath: "api")

        _ = try await reqresService.request(.post, path: "users", body: data)
    }

    @Test func postWithTypedBody() async throws {
        let user = User(name: "Test user", job: "dog walker")

        let reqresService = Service(host: "reqres.in", relativePath: "api")

        let responseUser: User = try await reqresService.request(.post, path: "users", body: user)

        #expect(responseUser.name == "Test user")
    }
}
