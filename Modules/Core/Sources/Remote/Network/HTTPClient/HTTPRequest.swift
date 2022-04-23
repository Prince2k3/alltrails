import Foundation
import Core
import Combine

public final class HTTPRequest {
    enum Exception: LocalizedError {
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "URL is either null or invalid"
            }
        }
    }
    
    public enum Method: String, Hashable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    private var base: URL
    public var path: String = ""
    public var httpMethod: Method = .get
    public var headers: [String: String] = .defaultHeaders
    public var httpBody: Data?
    public var queryItems: [String: String] = [:]
    
    public var url: URL? {
        guard var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        if !path.isEmpty {
            components.path = "/" + path
        }
        
        if !queryItems.isEmpty {
            components.setQueryItems(with: queryItems)
        }
        return components.url
    }
    
    
    public func makeURLRequest() throws -> URLRequest {
        guard let url = url else { throw Exception.invalidURL }
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.1, forHTTPHeaderField: $0.0) }
        request.httpBody = httpBody
        request.httpMethod = httpMethod.rawValue
        return request
    }
    
    public init(url: URL) {
        self.base = url
    }
    
    public func path(_ value: String) -> Self {
        path = value
        return self
    }
    
    public func httpBody(_ value: Data) -> Self {
        httpBody = value
        return self
    }
    
    public func httpBody<E: Encodable>(_ value: E, encoder: JSONEncoder = .init()) throws -> Self {
        httpBody = try encoder.encode(value)
        return self
    }
    
    public func httpMethod(_ value: Method) -> Self {
        httpMethod = value
        return self
    }
    
    public func query(_ value: [String: String]) -> Self {
        queryItems = value
        return self
    }
    
    public func headers(_ value: [String: String]) -> Self {
        headers = value
        return self
    }
    
    public func appendingHeaders(_ value: [String: String]) -> Self {
        headers = headers.merging(value) { $1 }
        return self
    }
    
    public func execute(on httpClient: HTTPClient) -> AnyPublisher<HTTPResponse, Error> {
        httpClient.execute(self)
    }
    
    public func callAsFunction() throws -> URLRequest {
        try makeURLRequest()
    }
}

extension HTTPRequest: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        URL: \(url?.absoluteString ?? "<Invalid URL>")
        HTTP Method: \(httpMethod.rawValue)
        Headers: \(headers)
        Body: \(httpBody?.string ?? "")
        """
    }
}

extension Dictionary where Key == String, Value == String {
    public static let defaultHeaders: [String: String] = ["Content-Type": "application/json"]
}
