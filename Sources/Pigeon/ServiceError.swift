import Foundation

public enum ServiceError: Error {
  case invalidURL
  case responseError(ResponseData)
}
