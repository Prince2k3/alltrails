import Foundation

extension Data {
    public var string: String? { String(decoding: self, as: UTF8.self) }
}
