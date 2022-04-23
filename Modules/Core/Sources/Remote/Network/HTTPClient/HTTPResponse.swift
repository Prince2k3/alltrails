import Foundation

public struct HTTPResponse  {
    let httpURLResponse: HTTPURLResponse
    
    public let data: Data
    
    public init(data: Data, httpURLResponse: HTTPURLResponse) {
        self.data = data
        self.httpURLResponse = httpURLResponse
    }
}

extension HTTPResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        HTTPURLResponse: \(String(describing: httpURLResponse.debugDescription))
        Body: \(data.string ?? "")
        Status Code: \(statusCode)
        """
    }
}

extension HTTPResponse {
    public var url: URL? {
        httpURLResponse.url
    }
    
    public var headers: [AnyHashable: String] {
        httpURLResponse.allHeaderFields
            .compactMapValues({ $0 as? String })
    }
    
    public var statusCode: Int {
        httpURLResponse.statusCode
    }
    
    public func decoded<T: Decodable>(as type: T.Type, using decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(type, from: data)
    }
}
