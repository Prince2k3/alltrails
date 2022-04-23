import Foundation
import Combine

public protocol SearchForRestaurantsUseCase {
    func searchRestaurants(_ searchText: String) -> AnyPublisher<[Restaurant], Error>
}
