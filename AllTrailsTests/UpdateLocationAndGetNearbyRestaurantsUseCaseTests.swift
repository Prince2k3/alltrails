import XCTest
import Combine
import Core
import Remote

@testable import AllTrails

class UpdateLocationAndGetNearbyRestaurantsUseCaseTests: XCTestCase {
    func test_userLocationUseCase_canUpdateLocation() {
        let spy = UpdateUserLocationUseCaseUseCaseSpy()

        let exp = expectation(description: "Waiting ...")
        exp.expectedFulfillmentCount = 2

        var output: [Location] = []
        let cancellable = spy.updateLocation().sinkValue { location in
            output.append(location)
            exp.fulfill()
        }

        let location = anyLocation()
        
        spy.sendUserLocation(location)
        spy.sendUserLocation(location)

        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(spy.receivedMessages, [.updatingLocation])
        XCTAssertEqual(output, [location, location])
        
        cancellable.cancel()
    }
    
    func test_useCase_withLocationGetNearbyRestaurants() {
        let updateUserLocationUseCaseSpy = UpdateUserLocationUseCaseUseCaseSpy()
        let httpClientSpy = HTTPClientSpy()
        let sut = UpdateLocationAndGetNearbyRestaurantsUseCase(
            userLocationObserverUseCase: updateUserLocationUseCaseSpy,
            remoteSearchNearbyRestaurantsUseCase: RemoteSearchNearbyRestaurantsUseCase(httpClient: httpClientSpy)
        )
        
        let exp = expectation(description: "Waiting ...")
        exp.expectedFulfillmentCount = 1

        var output: [[Restaurant]] = []
        let cancellable = sut.nearbyRestaurants().sinkValue { restaurants in
            output.append(restaurants)
            exp.fulfill()
        }

        let location = anyLocation()
        updateUserLocationUseCaseSpy.sendUserLocation(location)
        
        let response = anyValidResponse()
        httpClientSpy.completeNearbyRestaurants(response)
        
        wait(for: [exp], timeout: 1.0)
        
        let expected: [Restaurant] = [
            .init(name: "Test Restaurant 1", priceLevel: 2 , rating: 4, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 2", priceLevel: 1 , rating: 3, photoURL: nil, ratingCount: 40, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 3", priceLevel: 2 , rating: 3, photoURL: nil, ratingCount: 9, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 4", priceLevel: 2, rating: 2, photoURL: nil, ratingCount: 200, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 5", priceLevel:3, rating: 1, photoURL: nil, ratingCount: 1, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 6", priceLevel:4, rating: 1, photoURL: nil, ratingCount: 8, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 7", priceLevel: 4, rating: 2, photoURL: nil, ratingCount: 48, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 8", priceLevel: 2, rating: 3, photoURL: nil, ratingCount: 1500, location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 9", priceLevel: 2, rating: 4, photoURL: nil, ratingCount: 234,location: .init(latitude: 0, longitude: 0)),
            .init(name: "Test Restaurant 10", priceLevel: 3, rating: 4, photoURL: nil, ratingCount: 120, location: .init(latitude: 0, longitude: 0)),
        ]
        
        XCTAssertEqual(output, [expected])
        
        cancellable.cancel()
    }
    
    class UpdateUserLocationUseCaseUseCaseSpy: UpdateUserLocationUseCase {
        enum Message: Equatable {
            case updatingLocation
        }
        
        private var startUpdatingLocationPublisher = PassthroughSubject<Location, Never>()
        private(set) var receivedMessages = [Message]()
        
        func updateLocation() -> AnyPublisher<Location, Never> {
            receivedMessages.append(.updatingLocation)
            return startUpdatingLocationPublisher
                .eraseToAnyPublisher()
        }

        func sendUserLocation(_ location: Location) {
            startUpdatingLocationPublisher.send(location)
        }
    }
    
    class HTTPClientSpy: HTTPClient {
        private var requests: [Future<HTTPResponse, Error>.Promise] = []
        
        func execute(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, Error> {
            return Future { [weak self] in
                self?.requests.append($0)
            }
            .eraseToAnyPublisher()
        }
        
        func completeNearbyRestaurants(_ response: HTTPResponse, at index: Int = 0) {
            requests[index](.success(response))
        }
    }
    
    func anyLocation() -> Location {
        Location(latitude: 30.267, longitude: 97.7431)
    }
    
    func anyGooglePlaceResponse() -> GooglePlacesResponse {
        GooglePlacesResponse(results: [
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 1", openingHours: nil, photos: [], types: [], vicinity: "", rating: 4, userRatingsTotal: 10, priceLevel: 2),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 2", openingHours: nil, photos: [], types: [], vicinity: "", rating: 3, userRatingsTotal: 40, priceLevel: 1),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 3", openingHours: nil, photos: [], types: [], vicinity: "", rating: 3, userRatingsTotal: 9, priceLevel: 2),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 4", openingHours: nil, photos: [], types: [], vicinity: "", rating: 2, userRatingsTotal: 200, priceLevel: 2),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 5", openingHours: nil, photos: [], types: [], vicinity: "", rating: 1, userRatingsTotal: 1, priceLevel: 3),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 6", openingHours: nil, photos: [], types: [], vicinity: "", rating: 1, userRatingsTotal: 8, priceLevel: 4),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 7", openingHours: nil, photos: [], types: [], vicinity: "", rating: 2, userRatingsTotal: 48, priceLevel: 4),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 8", openingHours: nil, photos: [], types: [], vicinity: "", rating: 3, userRatingsTotal: 1500, priceLevel: 2),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 9", openingHours: nil, photos: [], types: [], vicinity: "", rating: 4, userRatingsTotal: 234, priceLevel: 2),
            .init(geometry: .init(location: .init(lat: 0, lng: 0)), name: "Test Restaurant 10", openingHours: nil, photos: [], types: [], vicinity: "", rating: 4, userRatingsTotal: 120, priceLevel: 3),
            
        ])
    }
    
    private func anyValidResponse() -> HTTPResponse {
        HTTPResponse(
            data: try! JSONEncoder().encode(anyGooglePlaceResponse()),
            httpURLResponse: HTTPURLResponse(
                url: URL(string: "https://any-url.com/")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )
    }
}

