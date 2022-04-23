import Combine

extension Publisher {
    public func sinkValue(_ receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
        ignoreError()
            .sink { receiveValue($0) }
    }
    
    public func ignoreSink() -> Cancellable {
        sinkValue { _ in }
    }
}
