import Combine

extension Publisher {
    public func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> Publishers.SwitchToLatest<P, Publishers.Map<Self, P>> {
        map(transform)
            .switchToLatest()
    }
}
