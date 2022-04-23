import Foundation
import Core
import Combine

final class LoggerHTTPClient: HTTPClient {
    private let httpClient: HTTPClient
    private let logger: LoggingProvider
    
    public init(httpClient: HTTPClient, logger: LoggingProvider) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    func execute(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error> {
        logRequest(request)
        return httpClient.execute(request)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.logResponse(response)
            })
            .eraseToAnyPublisher()
    }
    
    private func logRequest(_ request: HTTPRequest) {
        logger.info("""
        ---------------------------------------------
        [HTTP Request] URL: \(request.url?.absoluteString ?? "??")
        [HTTP Request] HTTP Method: \(request.httpMethod.rawValue)
        [HTTP Request] Headers: \(request.headers)
        [HTTP Request] BODY: \(request.httpBody?.string ?? "")
        ---------------------------------------------
        """)
    }
    
    private func logResponse(_ response: HTTPResponse) {
        logger.info("""
        ---------------------------------------------
        [HTTP Response] URL Response: \(response.httpURLResponse.url?.absoluteString ?? "")
        [HTTP Response] Status Code: \(response.httpURLResponse.statusCode)
        [HTTP Response] Headers: \(response.headers)
        [HTTP Response] Body: \(response.data.string ?? "Empty")
        ---------------------------------------------
        """)
    }
}

public extension HTTPClient {
    func logging(to logger: LoggingProvider) -> HTTPClient {
        LoggerHTTPClient(httpClient: self, logger: logger)
    }
}
