import Foundation
import Core
import Remote

struct Print: LoggingProvider {
    func debug(_ message: LogMessage) {
        print(message.description)
    }
    
    func info(_ message: LogMessage) {
        print(message.description)
    }
    
    func notice(_ message: LogMessage) {
        print(message.description)
    }
    
    func warn(_ message: LogMessage) {
        print(message.description)
    }
    
    func error(_ message: LogMessage) {
        print(message.description)
    }
    
    func critical(_ message: LogMessage) {
        print(message.description)
    }
}
