import Foundation
import XCTest
import Combine

@testable import Remote

class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        URLProtocolStub.requestObserver = nil
        URLProtocolStub.responseStub = nil
    }
    
    func test_client_executeRequests() {
        let sut = makeSUT()
        
        let requests = [
            anyRequest(httpMethod: .get),
            anyRequest(httpMethod: .put),
            anyRequest(httpMethod: .patch),
            anyRequest(httpMethod: .delete),
        ]
        
        for request in requests {
            expect(sut, executes: request)
        }
    }
    
    func test_client_returnsValidResponse() {
        let sut = makeSUT()
        
        URLProtocolStub.responseStub = URLProtocolStub.Response(
            data: anyValidJSONData(),
            response: anyHTTPURLResponse(),
            error: nil
        )
        
        expectHTTPClient(
            sut,
            with: anyRequest(httpMethod: .get),
            toCompleteWith: .success(anyValidResponse(data: anyValidJSONData()))
        )
    }
}

extension URLSessionHTTPClientTests {
    private func makeSUT() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return URLSessionHTTPClient(session: session)
    }
    
    private func expectHTTPClient(_ sut: URLSessionHTTPClient, with request: HTTPRequest, toCompleteWith expectedResult: Result<HTTPResponse, HTTPClientError>, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for response")
        var receivedResult: Result<HTTPResponse, HTTPClientError>?
        let cancellable = sut.execute(request)
            .sink(receiveCompletion: {
                if case let .failure(error as HTTPClientError)  = $0 {
                    receivedResult = .failure(error)
                }
                exp.fulfill()
            }) { response in
                receivedResult = .success(response)
            }
        
        wait(for: [exp], timeout: 1.0)
        cancellable.cancel()
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedResponse), .success(expectedResponse)):
            XCTAssertEqual(receivedResponse.data, expectedResponse.data, file: file, line: line)
            XCTAssertEqual(receivedResponse.url, expectedResponse.url, file: file, line: line)
            XCTAssertEqual(receivedResponse.statusCode, expectedResponse.statusCode, file: file, line: line)
        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected \(expectedResult), but got \(String(describing: receivedResult)) instead", file: file, line: line)
        }
    }
    
    private func expect(_ sut: URLSessionHTTPClient, executes request: HTTPRequest, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for request")
        var receivedRequest: URLRequest?
        
        URLProtocolStub.requestObserver = {
            receivedRequest = $0
            exp.fulfill()
        }
        
        let cancellable = sut.execute(request)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedRequest?.httpMethod, request.httpMethod.rawValue, file: file, line: line)
        XCTAssertEqual(receivedRequest?.url, request.url, file: file, line: line)
        XCTAssertTrue(request.headers.allSatisfy({ receivedRequest?.allHTTPHeaderFields?[$0.key] == $0.value }), file: file, line: line)
        XCTAssertEqual(receivedRequest?.httpBodyStream?.readfully(), request.httpBody, file: file, line: line)
        
        cancellable.cancel()
    }
    
    private func anyRequest(httpMethod: HTTPRequest.Method, data: Data) -> HTTPRequest {
        HTTPRequest(url: URL(string: "https://any-url.com/")!)
            .path("valid-path")
            .httpMethod(httpMethod)
            .headers(
                [
                    "Content-Type": "application/json",
                    "custom-header": "any-value"
                ]
            )
            .httpBody(data)
    }
    
    private func anyRequest(httpMethod: HTTPRequest.Method) -> HTTPRequest {
        HTTPRequest(url: URL(string: "https://any-url.com/")!)
            .path("valid-path")
            .httpMethod(httpMethod)
            .headers(
                [
                    "Content-Type": "application/json",
                    "custom-header": "any-value"
                ]
            )
    }
    
    private func invalidJSONData() -> Data {
        Data()
    }
    
    private func anyValidResponse(data: Data) -> HTTPResponse {
        HTTPResponse(
            data: data,
            httpURLResponse: anyHTTPURLResponse()
        )
        
    }
    
    private func anyHTTPURLResponse(statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://any-url.com/")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    private func anyValidEncodableModel() -> TestModel {
        TestModel(value: "SOME TEST VALUE")
    }
    
    private func anyValidJSONData() -> Data {
        try! JSONEncoder().encode(anyValidEncodableModel())
    }
}

struct TestModel: Codable {
    let value: String
}

final class URLProtocolStub: URLProtocol {
    static var requestObserver: ((URLRequest) -> Void)?
    static var responseStub: Response?
    
    struct Response {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        requestObserver?(request)
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.responseStub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}


fileprivate extension InputStream {
    func readfully() -> Data {
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        open()
        
        var amount = 0
        repeat {
            amount = read(&buffer, maxLength: buffer.count)
            if amount > 0 {
                result.append(buffer, count: amount)
            }
        } while amount > 0
        
        close()
        
        return result
    }
}
