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
        let data = try await service.request(.get,
                                             url: url,
                                             headers: [])
        #expect(data != nil)
    }

    @Test func requestWithPath() async throws {
        let data = try await service.request(.get,
                                             path: ["pokemon", "charmander"])
        #expect(data != nil)
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

        let response = try await reqresService.request(.post, path: "users", body: data)

        #expect(response != nil)
    }

    @Test func postWithTypedBody() async throws {
        let user = User(name: "Test user", job: "dog walker")

        let reqresService = Service(host: "reqres.in", relativePath: "api")

        let responseUser: User = try await reqresService.request(.post, path: "users", body: user)

        #expect(responseUser.name == "Test user")
    }
}
