import Foundation

public struct ImageAsset: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ImageAsset {
    public static let activePin = ImageAsset(rawValue: "active_pin")
    public static let inactivePin = ImageAsset(rawValue: "inactive_pin")
    public static let pin = ImageAsset(rawValue: "pin")
    public static let list = ImageAsset(rawValue: "list")
    public static let logo = ImageAsset(rawValue: "logo")
    public static let martisTrail = ImageAsset(rawValue: "martis_trail")
}
