import Foundation
import Combine
import Core
import MapKit
import SwiftUI

extension Restaurants {
    public final class ViewModel: ObservableObject {
        enum SortBy {
            case lowToHigh
            case highToLow
            case none
        }
        
        @Published var nearbyRestaurants: [Restaurant] = []
        @Published var restaurants: [Restaurant] = []
        @Published var searchResults: [Restaurant] = []
        @Published var selectedRestaurant: Restaurant?
        @Published var searchText: String = ""
        @Published var sortBy: SortBy = .none
        @Published var region: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.5052, longitude: -97.8203),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        private let getNearbyRestaurantsUseCase: GetNearbyRestaurantsUseCase
        private let searchForRestaurantsUseCase: SearchForRestaurantsUseCase
        private let UIScheduler: AnySchedulerOf<DispatchQueue>
        
        private var cancellable = Set<AnyCancellable>()
        
        public init(
            getNearbyRestaurantsUseCase: GetNearbyRestaurantsUseCase,
            searchForRestaurantsUseCase: SearchForRestaurantsUseCase,
            inputSearchFilterHandler: InputSearchFilterHandler,
            UIScheduler: AnySchedulerOf<DispatchQueue> = .main
        ) {
            self.getNearbyRestaurantsUseCase = getNearbyRestaurantsUseCase
            self.searchForRestaurantsUseCase = searchForRestaurantsUseCase
            self.UIScheduler = UIScheduler
            
            observe(inputSearchFilterHandler)
            
            // observe changes to the differents properties of getting restaurants
            Publishers.CombineLatest3($searchResults, $nearbyRestaurants, $sortBy)
                .map { (searched, restaurants, sortBy)-> ([Restaurant], SortBy) in
                    if !searched.isEmpty {
                        return (searched, sortBy)
                    } else {
                        return (restaurants, sortBy)
                    }
                }
                .map { restaurants, sortBy in
                    guard sortBy != .none else {
                        return restaurants
                    }

                    if sortBy == .highToLow {
                        return restaurants.sorted(by: { $0.rating > $1.rating })
                    } else {
                        return restaurants.sorted(by: { $0.rating < $1.rating })
                    }
                }
                .assign(to: &$restaurants)

        }
        
        func observe(_ searchInputHandler: InputSearchFilterHandler) {
            searchInputHandler.validate(
                $searchText.dropFirst().eraseToAnyPublisher(),
                onReset: { [weak self] in
                    self?.searchText = ""
                    self?.searchResults = []
                })
            .flatMapLatest { [searchForRestaurantsUseCase] text in
                searchForRestaurantsUseCase.searchRestaurants(text)
                    .replaceError(with: [])
            }
            .receive(on: UIScheduler)
            .assign(to: &$searchResults)
        }
        
        func getNearbyRestaurants() {
            getNearbyRestaurantsUseCase.nearbyRestaurants()
                .receive(on: UIScheduler)
                .handleEvents(receiveOutput: { [weak self] restaurants in
                    guard let self = self else { return }
                    
                    if let first = restaurants.first {
                        self.region = MKCoordinateRegion(
                            center: first.location.coordinate2D,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        self.selectedRestaurant = first
                    }
                })
                .replaceError(with: [])
                .assign(to: &$nearbyRestaurants)
        }
    }
}


extension RestaurantRow {
    init(_ restaurant: Restaurant, selected: Bool) {
        self.init(
            photoURL: restaurant.photoURL,
            name: restaurant.name,
            rating: Int(restaurant.rating),
            ratingCount: restaurant.ratingCount,
            priceLevel: restaurant.priceLevel.flatMap { $0 == 0 ? "Free" : [String](repeating: "$", count: $0).joined(separator: "") },
            otherInfo: "Supported Text", // not sure the data for this spot
            selected: selected
        )
    }
}
