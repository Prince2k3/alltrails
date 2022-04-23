import Foundation

public struct Restaurant: Identifiable, Hashable {
    public var id: Int { hashValue }
    
    public let name: String
    public let priceLevel: Int?
    public let rating: Double
    public let photoURL: URL?
    public let ratingCount: Int
    public let location: Location
    
    public init(name: String, priceLevel: Int?, rating: Double, photoURL: URL?, ratingCount: Int, location: Location) {
        self.name = name
        self.priceLevel = priceLevel
        self.rating = rating
        self.photoURL = photoURL
        self.ratingCount = ratingCount
        self.location = location
    }
}
