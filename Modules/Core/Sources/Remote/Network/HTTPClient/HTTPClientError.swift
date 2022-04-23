import Foundation

public enum HTTPClientError: LocalizedError, Equatable {
    case cannotMakeRequest
    case invalidHTTPResponse
    case statusCode(Int)
    case decoding(type: String)
    
    public var errorDescription: String? {
        switch self {
        case let .statusCode(code):
            return "Status Code \(code)"
        case .cannotMakeRequest: return "Cannot make request"
        case .invalidHTTPResponse: return "The response from server was invalid"
        case let .decoding(type): return "Failed to decode type \(type)"
        }
    }
}
