import Foundation
import Combine

public struct InputSearchFilterHandler {
    private let queue: DispatchQueue?
    
    public init(on queue: DispatchQueue? = nil) {
        self.queue = queue
    }
    
    public func validate(_ publisher: AnyPublisher<String, Never>, onReset: @escaping () -> Void = {}) -> AnyPublisher<String, Never> {
        queue.flatMap { queue in
            filter(
                publisher.debounce(for: .milliseconds(250), scheduler: queue)
                    .eraseToAnyPublisher()
                , onReset: onReset
            )
        } ?? filter(publisher, onReset: onReset)
    }
    
    private func filter(_ publisher: AnyPublisher<String, Never>, onReset: @escaping () -> Void = {}) -> AnyPublisher<String, Never> {
        publisher
            .removeDuplicates()
            .filter({
                if !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.count > 1 {
                    return true
                }
                
                onReset()
                return false
                
            })
            .eraseToAnyPublisher()
    }
}
