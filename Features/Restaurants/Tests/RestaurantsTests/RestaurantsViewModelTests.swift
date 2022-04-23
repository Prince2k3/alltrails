import XCTest
import Core
import CoreLocation
import Combine

@testable import Restaurants

final class RestaurantsViewModelTests: XCTestCase {
    func test_init_noMessagesRecieved() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    func test_getNearbyRestaurantsUseCase_receivesMessageOnce() {
        let (sut, spy) = makeSUT()
        
        sut.getNearbyRestaurants()
        
        XCTAssertEqual(spy.receivedMessages, [.nearbyRestaurants])
    }
    
    func test_searchForRestaurantsUseCase_receivesMessageOneToMany() {
        let (sut, spy) = makeSUT()
        
        sut.searchText = "Sta"
        sut.searchText = "Starbu"
        sut.searchText = "Starbucks"
        
        XCTAssertEqual(
            spy.receivedMessages,
            [
                .searchRestaurants("Sta"),
                .searchRestaurants("Starbu"),
                .searchRestaurants("Starbucks"),
            ]
        )
    }
    
    func test_sortBy_sortsCorrectly() {
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "Waiting ...")
        exp.expectedFulfillmentCount = 5
        
        var output: [[Restaurant]] = []
        let cancellable = sut.$restaurants.sinkValue { restaurants in
            output.append(restaurants)
            exp.fulfill()
        }
        
        sut.getNearbyRestaurants()
        spy.completeNearbyRestaurants(
            [
                .init(name: "Test Restaurant 1", priceLevel: 2 , rating: 2, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 2", priceLevel: 1 , rating: 3, photoURL: nil, ratingCount: 40, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 3", priceLevel: 2 , rating: 1, photoURL: nil, ratingCount: 9, location: .init(latitude: 0, longitude: 0)),
            ]
        )
        
        sut.sortBy = .highToLow
        sut.sortBy = .lowToHigh
        sut.sortBy = .none
        
        wait(for: [exp], timeout: 1.0)
        
        let expected: [[Restaurant]] = [
            [], // on init
            [
                .init(name: "Test Restaurant 1", priceLevel: 2 , rating: 2, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 2", priceLevel: 1 , rating: 3, photoURL: nil, ratingCount: 40, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 3", priceLevel: 2 , rating: 1, photoURL: nil, ratingCount: 9, location: .init(latitude: 0, longitude: 0)),
            ],
            [
                .init(name: "Test Restaurant 2", priceLevel: 1 , rating: 3, photoURL: nil, ratingCount: 40, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 1", priceLevel: 2 , rating: 2, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 3", priceLevel: 2 , rating: 1, photoURL: nil, ratingCount: 9, location: .init(latitude: 0, longitude: 0)),
            ],
            [
                .init(name: "Test Restaurant 3", priceLevel: 2 , rating: 1, photoURL: nil, ratingCount: 9, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 1", priceLevel: 2 , rating: 2, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 2", priceLevel: 1 , rating: 3, photoURL: nil, ratingCount: 40, location: .init(latitude: 0, longitude: 0)),
            ],
            [
                .init(name: "Test Restaurant 1", priceLevel: 2 , rating: 2, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 2", priceLevel: 1 , rating: 3, photoURL: nil, ratingCount: 40, location: .init(latitude: 0, longitude: 0)),
                .init(name: "Test Restaurant 3", priceLevel: 2 , rating: 1, photoURL: nil, ratingCount: 9, location: .init(latitude: 0, longitude: 0)),
            ]
        ]
        
        XCTAssertEqual(output, expected)
        cancellable.cancel()
    }
    
    func test_search_deliversRequestedRestaurants() {
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "Waiting ...")
        exp.expectedFulfillmentCount = 2
        
        var output: [[Restaurant]] = []
        let cancellable = sut.$restaurants.sinkValue { restaurants in
            output.append(restaurants)
            exp.fulfill()
        }
        
        let resturant = Restaurant(name: "Pizza R.", priceLevel: 1, rating: 3, photoURL: nil, ratingCount: 10, location: .init(latitude: 0, longitude: 0))
        
        sut.searchText = "Pizza"
        
        spy.completeSearchRestaurants([resturant])
        wait(for: [exp], timeout: 1.0)
        
        let expected = [
            [],
            [resturant]
        ]
        
        XCTAssertEqual(output, expected)
        
        cancellable.cancel()
    }
    
    // Helpers
    
    func makeSUT() -> (Restaurants.ViewModel, UseCaseSpy) {
        let spy = UseCaseSpy()
        let viewModel = Restaurants.ViewModel(
            getNearbyRestaurantsUseCase: spy,
            searchForRestaurantsUseCase: spy,
            inputSearchFilterHandler: InputSearchFilterHandler(),
            UIScheduler: .immediate
        )
        
        return (viewModel, spy)
    }
    
    class UseCaseSpy: GetNearbyRestaurantsUseCase, SearchForRestaurantsUseCase {
        enum Message: Equatable {
            case nearbyRestaurants
            case searchRestaurants(String)
        }
        
        private var restaurantRequests: [Future<[Restaurant], Error>.Promise] = []
        private var searchRestaurantRequests: [Future<[Restaurant], Error>.Promise] = []
        private(set) var receivedMessages = [Message]()
        
        
        func nearbyRestaurants() -> AnyPublisher<[Restaurant], Error> {
            receivedMessages.append(.nearbyRestaurants)
            return Future { [weak self] in
                self?.restaurantRequests.append($0)
            }
            .eraseToAnyPublisher()
        }
        
        func searchRestaurants(_ searchText: String) -> AnyPublisher<[Restaurant], Error> {
            receivedMessages.append(.searchRestaurants(searchText))
            return Future { [weak self] in
                self?.searchRestaurantRequests.append($0)
            }
            .eraseToAnyPublisher()
        }
        
        func completeNearbyRestaurants(_ restaurants: [Restaurant], at index: Int = 0) {
            restaurantRequests[index](.success(restaurants))
        }
        
        func completeSearchRestaurants(_ restaurants: [Restaurant], at index: Int = 0) {
            searchRestaurantRequests[index](.success(restaurants))
        }
    }
}
