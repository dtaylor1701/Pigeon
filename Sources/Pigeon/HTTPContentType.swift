import Foundation

public enum HTTPContentType: String {
  case json = "application/json"
}

extension HTTPContentType: HTTPHeaderConvertable {
  public func asHTTPHeader() -> HTTPHeader? {
    HTTPHeader(field: .contentType, value: self.rawValue)
  }
}
