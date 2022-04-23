import Combine

extension Publisher {
    public func setFailureTypeToAnyError() -> AnyPublisher<Output, Error> {
        mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    public func ignoreError() -> AnyPublisher<Output, Never> {
        self.catch { _ in Empty() }.eraseToAnyPublisher()
    }
}
