import Foundation

public protocol HTTPClientAdapter {}

public protocol HTTPClientRequestAdapter: HTTPClientAdapter {
    func respond(to request: HTTPRequest)
}

public protocol HTTPClientResponseAdapter: HTTPClientAdapter {
    func respond(to response: HTTPResponse)
}
