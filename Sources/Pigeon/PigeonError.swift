import Foundation

public enum PigeonError: Error {
  case invalidURL
  case responseError(response: HTTPURLResponse, body: String?)
  static func responseError(_ responseData: ResponseData) -> PigeonError {
    return .responseError(
      response: responseData.response, body: String(data: Data(responseData.data), encoding: .utf8))
  }
}
