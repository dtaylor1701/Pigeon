import Foundation

public enum ServiceError: Error {
    case invalidURL
    case emptyResponseData
    case responseError(code: Int, body: Data?)
}
