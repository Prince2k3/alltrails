import Foundation
import Core
import Combine

final class HTTPClientValidation: HTTPClient {
    private let httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func execute(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error> {
        httpClient.execute(request)
            .tryMap({ response in
                guard (200..<400) ~= response.statusCode else {
                    throw HTTPClientError.statusCode(response.statusCode)
                }
                return response
            })
            .eraseToAnyPublisher()
    }
}

public extension HTTPClient {
    func validate() -> HTTPClient {
        HTTPClientValidation(httpClient: self)
    }
}
