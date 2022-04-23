import Core
import Foundation

extension Restaurant {
    init( _ place: GooglePlacesResponse.Place) {
        func makeURL(from ref: String) -> URL? {
            guard !ref.isEmpty,
                  var components = URLComponents(url: URL.googlePlacesURL, resolvingAgainstBaseURL: false) else {
                return nil
            }
            
            components.path = "/maps/api/place/photo"
            components.setQueryItems(with: [
                "maxWidth": "400",
                "photo_reference": ref,
                "key": "AIzaSyDue_S6t9ybh_NqaeOJDkr1KC9a2ycUYuE"
            ])
            return components.url
        }
        
        self.init(
            name: place.name,
            priceLevel: place.priceLevel,
            rating: place.rating,
            photoURL: makeURL(from: place.photos.first?.photoReference ?? ""),
            ratingCount: place.userRatingsTotal,
            location: Location(
                latitude: place.geometry.location.lat,
                longitude: place.geometry.location.lng
            )
        )
    }
}
