import XCTest
import SwiftUI
import Combine
import Core

final class InputSearchHandlerTests: XCTestCase {
    
    func test_searchHandler_whenInputTheSameValueTwice_removeDuplicates() {
        expect(["Test"], when: { valueSubject in
            valueSubject.send("Test")
            valueSubject.send("Test")
        })
    }
    
    func test_inputFilter_ignoresEmptyInput() {
        expect([], when: { valueSubject in
            valueSubject.send("")
            valueSubject.send(" ")
        }, configureExpectation: {
            $0.isInverted = true
        })
    }
    
    func test_inputFilter_ignoresInputWithLessThan2Characters() {
        expect(["AB", "ABC", "ABCD"], when: { valueSubject in
            valueSubject.send("A")
            valueSubject.send("AB")
            valueSubject.send("ABC")
            valueSubject.send("ABCD")
        }, configureExpectation: {
            $0.expectedFulfillmentCount = 2
        })
    }
}

extension InputSearchHandlerTests {
    
    private func makeSUT() -> InputSearchFilterHandler {
        InputSearchFilterHandler(on: nil)
    }
    
    private func expect(_ expectedValues: [String], when action: (CurrentValueSubject<String, Never>) -> Void, configureExpectation: (XCTestExpectation) -> Void = { _ in }) {
        let publisher = CurrentValueSubject<String, Never>("")
        let sut = makeSUT()
        let exp = expectation(description: "Wait for events")
        exp.assertForOverFulfill = false
        configureExpectation(exp)
        
        var receivedValues = [String]()
        let cancellable = sut.validate(publisher.dropFirst().eraseToAnyPublisher()).sink {
            receivedValues.append($0)
            exp.fulfill()
        }
        
        action(publisher)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedValues, expectedValues)
        cancellable.cancel()
    }
}
