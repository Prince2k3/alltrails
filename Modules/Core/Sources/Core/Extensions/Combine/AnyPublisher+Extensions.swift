import Combine

extension AnyPublisher {
    public static func empty() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    public static func never() -> AnyPublisher<Never, Failure> {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }

    public static func fail(_ failure: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: failure).eraseToAnyPublisher()
    }

    public static func fail(outputType: Output.Type, failure: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: failure).eraseToAnyPublisher()
    }

    public static func just(_ output: Output) -> AnyPublisher<Output, Never> {
        Just(output).eraseToAnyPublisher()
    }

    public static func deferred<P: Publisher>(_ createPublisher: @escaping () -> P) -> AnyPublisher<P.Output, P.Failure> {
        Deferred(createPublisher: createPublisher).eraseToAnyPublisher()
    }

    public static func future(_ attemptToFulfill: @escaping (@escaping Future<Output, Failure>.Promise) -> Void) -> AnyPublisher<Output, Failure> {
        Future(attemptToFulfill).eraseToAnyPublisher()
    }

    public static func result(_ success: Output) -> AnyPublisher<Output, Failure> {
        Result<Output, Failure>.Publisher(success).eraseToAnyPublisher()
    }

    public static func result(_ failure: Failure) -> AnyPublisher<Output, Failure> {
        Result<Output, Failure>.Publisher(failure).eraseToAnyPublisher()
    }
}
