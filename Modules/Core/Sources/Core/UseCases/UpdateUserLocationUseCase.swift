import Foundation
import CoreLocation
import Combine

public protocol UpdateUserLocationUseCase {
    func updateLocation() -> AnyPublisher<Location, Never>
}
