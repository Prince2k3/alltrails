import CoreLocation
import Combine

extension CLLocationManager {
    public var publisher: CLLocationManager.Publisher {
        return CLLocationManager.Publisher(locationManager: self)
    }
}

extension CLLocationManager {
    public final class Publisher: NSObject, CLLocationManagerDelegate, Combine.Publisher {
        public typealias Output = LocationState
        public typealias Failure = Error

        private weak var locationManager: CLLocationManager?

        private var subscriptions: [CLLocationManager.Subscription] = []

        public init(locationManager: CLLocationManager) {
            self.locationManager = locationManager
            self.subscriptions = []

            super.init()

            locationManager.delegate = self
        }

        fileprivate func remove(subscription: CLLocationManager.Subscription) {
            subscriptions.removeAll(where: { $0 === subscription })
        }

        public func receive<S>(subscriber: S) where S: Subscriber, CLLocationManager.Publisher.Failure == S.Failure, CLLocationManager.Publisher.Output == S.Input {
            let subscription = CLLocationManager.Subscription(publisher: self, subscriber: subscriber)
            self.subscriptions.append(subscription)
            subscriber.receive(subscription: subscription)
        }

        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            subscriptions.forEach { $0.handleValue(.authorizationChange(status)) }
        }

        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            subscriptions.forEach { $0.handleValue(.locations(locations)) }
        }

        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            subscriptions.forEach { $0.handleValue(.error(error)) }
        }

        public var errors: AnyPublisher<Error, Never> {
            compactMap { data in
                switch data {
                case let .error(error):
                    return error
                default:
                    return nil
                }
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
        }

        public var locations: AnyPublisher<[CLLocation], Never> {
            compactMap { data in
                switch data {
                case .locations(let locations):
                    return locations
                default:
                    return nil
                }
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
        }

        public var status: AnyPublisher<CLAuthorizationStatus, Never> {
            compactMap { data in
                switch data {
                case let .authorizationChange(status):
                    return status
                default:
                    return nil
                }
            }
            .assertNoFailure()
            .eraseToAnyPublisher()
        }
    }
}

extension CLLocationManager {
    final class Subscription: Combine.Subscription {
        let subscriber: AnySubscriber<LocationState, Error>

        var publisher: CLLocationManager.Publisher?
        var currentDemand: Subscribers.Demand = .unlimited

        init<S: Subscriber>(publisher: CLLocationManager.Publisher, subscriber: S) where S.Failure == Error, S.Input == LocationState {
            self.subscriber = subscriber.eraseToAnySubscriber()
            self.publisher = publisher
        }

        func request(_ demand: Subscribers.Demand) {
            currentDemand = demand
        }

        func handleValue(_ value: LocationState) {
            let additionalDemand = subscriber.receive(value)
            currentDemand += additionalDemand

            if currentDemand <= 0 {
                subscriber.receive(completion: .finished)
                publisher?.remove(subscription: self)
            }
        }

        func cancel() {
            publisher?.remove(subscription: self)
        }
    }
}

extension CLLocationManager {
    public enum LocationState {
        case locations([CLLocation])
        case authorizationChange(CLAuthorizationStatus)
        case error(Error)
    }
}


extension Subscriber {
    public func eraseToAnySubscriber() -> AnySubscriber<Self.Input, Self.Failure> {
        return AnySubscriber<Input, Failure>.init(receiveSubscription: {
            self.receive(subscription: $0)
        }, receiveValue: { value in
            self.receive(value)
        }, receiveCompletion: { completion in
            self.receive(completion: completion)
        })
    }
}
