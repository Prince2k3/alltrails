import Foundation

public protocol LoggingProvider {
    func debug(_ message: LogMessage)
    func info(_ message: LogMessage)
    func notice(_ message: LogMessage)
    func warn(_ message: LogMessage)
    func error(_ message: LogMessage)
    func critical(_ message: LogMessage)
}

public struct LogMessage: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    
    public let message: String
    public let attributes: [String: Encodable]?
    
    public init(message: String, attributes: [String: Encodable]?) {
        self.message = message
        self.attributes = attributes
    }

    public init(stringLiteral value: StringLiteralType) {
        self.message = value
        self.attributes = nil
    }
}

extension LogMessage: CustomStringConvertible {
    public var description: String { message }
}
