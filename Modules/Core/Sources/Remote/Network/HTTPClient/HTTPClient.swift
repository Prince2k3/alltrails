import Foundation
import Combine

public protocol HTTPClient {
    func execute(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error>
}
