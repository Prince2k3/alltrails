import Foundation
import Core
import Remote
import Combine

final class UpdateLocationAndSearchNearbyRestaurantsUseCase: SearchForRestaurantsUseCase {
    let userLocationObserverUseCase: UpdateUserLocationUseCase
    let remoteSearchNearbyRestaurantsUseCase: RemoteSearchNearbyRestaurantsUseCase
    
    init(userLocationObserverUseCase: UpdateUserLocationUseCase, remoteSearchNearbyRestaurantsUseCase: RemoteSearchNearbyRestaurantsUseCase) {
        self.userLocationObserverUseCase = userLocationObserverUseCase
        self.remoteSearchNearbyRestaurantsUseCase = remoteSearchNearbyRestaurantsUseCase
    }
    
    func searchRestaurants(_ searchText: String) -> AnyPublisher<[Restaurant], Error> {
        userLocationObserverUseCase.updateLocation()
            .removeDuplicates()
            .flatMap { [remoteSearchNearbyRestaurantsUseCase] location in
                remoteSearchNearbyRestaurantsUseCase.searchNearbyRestaurants(keyword: searchText, location: location)
            }
            .eraseToAnyPublisher()
    }
}
