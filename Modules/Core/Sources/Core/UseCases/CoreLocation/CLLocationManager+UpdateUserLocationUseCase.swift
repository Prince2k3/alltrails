import Foundation
import CoreLocation
import Combine

extension CLLocationManager: UpdateUserLocationUseCase {
    public func updateLocation() -> AnyPublisher<Location, Never> {
        publisher.locations
            .compactMap { $0.first }
            .map { Location(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .eraseToAnyPublisher()
    }
}
