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

    // MARK: - Performs request using service session.

    public func request<Body: Encodable>(_ method: HTTPMethod,
                                         url: URL,
                                         headers: [HTTPHeader],
                                         body: Body?) async throws -> ResponseData {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.add(headers: headers)
        request.httpBody = try encodeBody(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let responseData = ResponseData(response: httpResponse, data: data)

        guard httpResponse.statusCode < 300 else {
            throw ServiceError.responseError(responseData)
        }

        return responseData
    }

    public func request(_ method: HTTPMethod,
                        url: URL,
                        headers: [HTTPHeader]) async throws -> ResponseData {
        try await request(method, url: url, headers: headers, body: Data?.none)
    }

    public func request<Body: Encodable,
                        ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    url: URL,
                                                    headers: [HTTPHeader],
                                                    body: Body?) async throws -> ResponseContent {
        let responseData = try await request(method, url: url, headers: headers, body: body)
        return try decoder.decode(ResponseContent.self, from: responseData.data)
    }

    public func request<ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    url: URL,
                                                    headers: [HTTPHeader]) async throws -> ResponseContent {
        try await request(method, url: url, headers: headers, body: Data?.none)
    }

    public func request<Body: Encodable>(_ method: HTTPMethod,
                                         components: URLComponents,
                                         headers: [HTTPHeader],
                                         body: Body? = nil) async throws -> ResponseData {
        guard let url = components.url else {
            throw ServiceError.invalidURL
        }

        return try await request(method, url: url, headers: headers, body: body)
    }

    public func request<Body: Encodable,
                        ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    components: URLComponents,
                                                    headers: [HTTPHeader],
                                                    body: Body?) async throws -> ResponseContent {
        guard let url = components.url else {
            throw ServiceError.invalidURL
        }

        return try await request(method, url: url, headers: headers, body: body)
    }

    public func request(_ method: HTTPMethod,
                        components: URLComponents,
                        headers: [HTTPHeader]) async throws -> ResponseData {
        try await request(method, components: components, headers: headers, body: Data?.none)
    }

    public func request<ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    components: URLComponents,
                                                    headers: [HTTPHeader]) async throws -> ResponseContent {
        try await request(method, components: components, headers: headers, body: Data?.none)
    }

    // MARK: - Uses service state.

    public func request<Body: Encodable>(_ method: HTTPMethod,
                                         path: URLPath,
                                         queryItems: [URLQueryItem]? = nil,
                                         body: Body?) async throws -> ResponseData {
        var components = self.components(path: path)
        components.queryItems = queryItems

        return try await request(method, components: components, headers: defaultHeaders(), body: body)
    }

    public func request<Body: Encodable,
                        ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    path: URLPath,
                                                    queryItems: [URLQueryItem]? = nil,
                                                    body: Body?) async throws -> ResponseContent {
        var components = self.components(path: path)
        components.queryItems = queryItems

        return try await request(method, components: components, headers: defaultHeaders(), body: body)
    }

    public func request(_ method: HTTPMethod,
                        path: URLPath,
                        queryItems: [URLQueryItem]? = nil) async throws -> ResponseData {
        try await request(method, path: path, queryItems: queryItems, body: Data?.none)
    }

    public func request<ResponseContent: Decodable>(_ method: HTTPMethod,
                                                    path: URLPath,
                                                    queryItems: [URLQueryItem]? = nil) async throws -> ResponseContent {
        try await request(method, path: path, queryItems: queryItems, body: Data?.none)
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

    private func encodeBody<Body: Encodable>(_ body: Body?) throws -> Data? {
        guard let body = body else { return nil }
        if let data = body as? Data { return data }
        return try encoder.encode(body)
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
