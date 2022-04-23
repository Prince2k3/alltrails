import Foundation
import Core
import Remote
import Combine

final class UpdateLocationAndGetNearbyRestaurantsUseCase: GetNearbyRestaurantsUseCase {
    let userLocationObserverUseCase: UpdateUserLocationUseCase
    let remoteSearchNearbyRestaurantsUseCase: RemoteSearchNearbyRestaurantsUseCase
    
    init(userLocationObserverUseCase: UpdateUserLocationUseCase, remoteSearchNearbyRestaurantsUseCase: RemoteSearchNearbyRestaurantsUseCase) {
        self.userLocationObserverUseCase = userLocationObserverUseCase
        self.remoteSearchNearbyRestaurantsUseCase = remoteSearchNearbyRestaurantsUseCase
    }
    
    func nearbyRestaurants() -> AnyPublisher<[Restaurant], Error> {
        userLocationObserverUseCase.updateLocation()
            .removeDuplicates()
            .flatMap { [remoteSearchNearbyRestaurantsUseCase] location in
                remoteSearchNearbyRestaurantsUseCase.searchNearbyRestaurants(location: location)
            }
            .eraseToAnyPublisher()
    }
}
