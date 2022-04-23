import Foundation
import Combine
import Core

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func execute(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error> {
        guard let request = try? request() else {
            return .result(HTTPClientError.cannotMakeRequest)
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                let (data, urlResponse) = result
                
                guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                    throw HTTPClientError.invalidHTTPResponse
                }
                
                let response = HTTPResponse(data: data, httpURLResponse: httpURLResponse)
                
                return response
            }
            .setFailureTypeToAnyError()
    }
}
