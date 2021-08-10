import Foundation
import Combine

open class Service {
    public var host: String
    public var relativePath: URLPath
    public var port: Int?
    public var scheme: HTTPScheme = .https
    public var authorization: HTTPAuthorization?
    public var contentType: HTTPContentType? = .json

    public var session = URLSession(configuration: .default)
    public var encoder = JSONEncoder()
    public var decoder = JSONDecoder()

    public init(host: String, relativePath: URLPath = []) {
        self.host = host
        self.relativePath = relativePath
    }

    public func test() async {
        print("test")
    }

    // MARK: - Performs request using service session.
    public func request(_ method: HTTPMethod,
                        url: URL,
                        headers: [HTTPHeader],
                        body: Data?) async throws -> Data? {
        print("~~~" + url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.add(headers: headers)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode < 300 else {
            throw ServiceError.responseError(code: httpResponse.statusCode, body: data)
        }

        return data
    }

    public func request(_ method: HTTPMethod,
                        components: URLComponents,
                        headers: [HTTPHeader],
                        body: Data?) async throws -> Data? {
        guard let url = components.url else {
            throw ServiceError.invalidURL
        }

        return try await request(method, url: url, headers: headers, body: body)
    }

    // MARK: - Uses service state.
    public func request(_ method: HTTPMethod,
                        path: URLPath,
                        queryItems: [URLQueryItem]? = nil,
                        body: Data? = nil) async throws -> Data? {
        var components = self.components(path: path)
        components.queryItems = queryItems

        return try await request(method, components: components, headers: defaultHeaders(), body: body)
    }

    public func request<Body: Encodable>(_ method: HTTPMethod,
                                         path: URLPath,
                                         queryItems: [URLQueryItem]? = nil,
                                         body: Body) async throws -> Data? {
        var components = self.components(path: path)
        components.queryItems = queryItems

        let encodedBody: Data = try encoder.encode(body)

        return try await request(method, components: components, headers: defaultHeaders(), body: encodedBody)
    }

    public func request<ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    path: URLPath,
                                                    queryItems: [URLQueryItem]? = nil,
                                                    body: Data? = nil) async throws -> ResponseContent {
        let data = try await request(method, path: path, queryItems: queryItems, body: body)
        guard let data = data else { throw ServiceError.emptyResponseData }
        return try decoder.decode(ResponseContent.self, from: data)
    }

    public func request<Body: Encodable,
                        ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    path: URLPath,
                                                    queryItems: [URLQueryItem]? = nil,
                                                    body: Body) async throws -> ResponseContent {
        let data = try await request(method, path: path, queryItems: queryItems, body: body)
        guard let data = data else { throw ServiceError.emptyResponseData }
        return try decoder.decode(ResponseContent.self, from: data)
    }

    open func defaultHeaders() -> [HTTPHeader] {
        var headers: [HTTPHeader] = []

        if let contentTypeHeader = self.contentType?.asHTTPHeader() {
            headers.append(contentTypeHeader)
        }

        if let authorizationHeader = self.authorization?.asHTTPHeader() {
            headers.append(authorizationHeader)
        }

        return headers
    }

    private func components(path: URLPath) -> URLComponents {
        var components = URLComponents()
        components.host = host
        components.port = port
        components.path = (relativePath + path).fullPath
        components.scheme = scheme.rawValue
        return components
    }
}
