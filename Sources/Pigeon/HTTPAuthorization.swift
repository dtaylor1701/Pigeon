import Foundation

public enum HTTPAuthorization {
    case basic(username: String, password: String)
    case bearer(token: String)
    case other(value: String)

    public var headerValue: String? {
        switch self {
        case .basic(let username, let password):
            let data = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)
            guard let encoded = data?.base64EncodedString() else { return nil }
            return "Basic \(encoded)"
        case .bearer(let token):
            return "Bearer \(token)"
        case .other(let value):
            return value
        }
    }
}

extension HTTPAuthorization: HTTPHeaderConvertable {
    public func asHTTPHeader() -> HTTPHeader? {
        guard let value = headerValue else { return nil }
        return HTTPHeader(field: .authorization, value: value)
    }
}
