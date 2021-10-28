import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct URLPath: ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
    public var components: [String]

    public var fullPath: String {
        return "/\(components.joined(separator: "/"))"
    }

    public init(components: [String]) {
        self.components = components
    }

    public init(_ components: String...) {
        self.init(components: components)
    }

    public init(arrayLiteral elements: String...) {
        self.init(components: elements)
    }

    public init(stringLiteral value: String) {
        self.init(components: [value])
    }
}

public extension URLPath {
    static func + (left: URLPath, right: URLPath) -> URLPath {
        URLPath(components: left.components + right.components)
    }
}
