import Foundation

public class LoggingProviderComposite: LoggingProvider {
    private let providers: [LoggingProvider]
    
    public init(providers: [LoggingProvider] = []) {
        self.providers = providers
    }
    
    public func debug(_ message: LogMessage) {
        providers.forEach({ $0.debug(message) })
    }
    
    public func info(_ message: LogMessage) {
        providers.forEach({ $0.info(message) })
    }
    
    public func notice(_ message: LogMessage) {
        providers.forEach({ $0.notice(message) })
    }
    
    public func warn(_ message: LogMessage) {
        providers.forEach({ $0.warn(message) })
    }
    
    public func error(_ message: LogMessage) {
        providers.forEach({ $0.error(message) })
    }
    
    public func critical(_ message: LogMessage) {
        providers.forEach({ $0.critical(message) })
    }
}

