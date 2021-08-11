import XCTest
@testable import Pigeon

final class ServiceTests: XCTestCase {
    var service: Service!

    override func setUpWithError() throws {
        service = Service(host: "pokeapi.co", relativePath: ["api", "v2"])
    }

    func testRequestWithURL() async throws {
        let url = try XCTUnwrap(URL(string: "https://pokeapi.co/api/v2/pokemon/charmander"))
        let data = try await service.request(.get,
                                             url: url,
                                             headers: [])
        XCTAssertNotNil(data)
    }

    func testRequestWithPath() async throws {
        let data = try await service.request(.get,
                                             path: ["pokemon", "charmander"])
        XCTAssertNotNil(data)
    }

    func testRequestTypedResponse() async throws {
        service.decoder.keyDecodingStrategy = .convertFromSnakeCase
        let charmander: Pokemon = try await service.request(.get,
                                                            path: ["pokemon", "charmander"])
        XCTAssertEqual(charmander.name, "charmander")
    }

    func testPostWithBodyData() async throws {
        let user = User(name: "Test user", job: "dog walker")
        let data = try JSONEncoder().encode(user)

        service = Service(host: "reqres.in", relativePath: "api")

        let response = try await service.request(.post, path: "users", body: data)

        XCTAssertNotNil(response)
    }

    func testPostWithTypedBody() async throws {
        let user = User(name: "Test user", job: "dog walker")

        service = Service(host: "reqres.in", relativePath: "api")

        let responseUser: User = try await service.request(.post, path: "users", body: user)

        XCTAssertEqual(responseUser.name, "Test user")
    }
}
