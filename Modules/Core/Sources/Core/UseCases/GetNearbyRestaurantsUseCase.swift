import Foundation
import Combine
import CoreLocation

public protocol GetNearbyRestaurantsUseCase {
    func nearbyRestaurants() -> AnyPublisher<[Restaurant], Error>
}
