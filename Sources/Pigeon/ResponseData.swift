import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct ResponseData {
  public let response: HTTPURLResponse
  public let data: Data
}
