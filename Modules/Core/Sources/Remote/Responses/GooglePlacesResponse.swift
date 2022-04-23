import Foundation

public struct GooglePlacesResponse: Codable {
    let results: [Place]
    
    public init(results: [GooglePlacesResponse.Place]) {
        self.results = results
    }
}

extension GooglePlacesResponse {
    public struct Place: Codable {
        let geometry: Location
        let name: String
        let openingHours: OpenNow?
        let photos: [Photo]
        let types: [String]
        let vicinity: String
        let rating: Double
        let userRatingsTotal: Int
        let priceLevel: Int?
        
        public init(
            geometry: GooglePlacesResponse.Location,
            name: String,
            openingHours: GooglePlacesResponse.OpenNow?,
            photos: [GooglePlacesResponse.Photo],
            types: [String],
            vicinity: String,
            rating: Double,
            userRatingsTotal: Int,
            priceLevel: Int?
        ) {
            self.geometry = geometry
            self.name = name
            self.openingHours = openingHours
            self.photos = photos
            self.types = types
            self.vicinity = vicinity
            self.rating = rating
            self.userRatingsTotal = userRatingsTotal
            self.priceLevel = priceLevel
        }
    }

    public struct Location: Codable {
        let location: Coordinate
        
        public init(location: GooglePlacesResponse.Coordinate) {
            self.location = location
        }
    }
    
    public struct Coordinate: Codable {
        let lat: Double
        let lng: Double
        
        public init(lat: Double, lng: Double) {
            self.lat = lat
            self.lng = lng
        }
    }

    public struct OpenNow: Codable {
        let openNow: Bool
    }

    public struct Photo: Codable {
        let height: Int
        let width: Int
        let photoReference: String
    }
}
