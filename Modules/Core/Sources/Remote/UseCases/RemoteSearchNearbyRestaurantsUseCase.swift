import Foundation
import Combine
import Core

public final class RemoteSearchNearbyRestaurantsUseCase {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func searchNearbyRestaurants(keyword: String = "", location: Location) -> AnyPublisher<[Core.Restaurant], Error> {
        HTTPRequest(url: .googlePlacesURL)
            .path("maps/api/place/nearbysearch/json")
            .query(
                [
                    "keyword": keyword,
                    "location": "\(location.latitude),\(location.longitude)",
                    "radius": "50000",
                    "type": "restaurant",
                    "key": "AIzaSyDue_S6t9ybh_NqaeOJDkr1KC9a2ycUYuE",
                ]
            )
            .httpMethod(.post)
            .execute(on: httpClient)
            .tryMap { response -> [GooglePlacesResponse.Place] in
                try response.decoded(as: GooglePlacesResponse.self, using: .default).results
            }
            .map { $0.map(Core.Restaurant.init) }
            .setFailureTypeToAnyError()
    }
}


extension JSONDecoder {
    static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
