// https://github.com/pointfreeco/combine-schedulers
import Combine
import Foundation

public struct AnyScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    private let _minimumTolerance: () -> SchedulerTimeType.Stride
    private let _now: () -> SchedulerTimeType
    private let _scheduleAfterIntervalToleranceOptionsAction: (
        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerTimeType.Stride,
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Cancellable
    
    private let _scheduleAfterToleranceOptionsAction: (
        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Void
    
    private let _scheduleOptionsAction: (SchedulerOptions?, @escaping () -> Void) -> Void
    
    /// The minimum tolerance allowed by the scheduler.
    public var minimumTolerance: SchedulerTimeType.Stride { self._minimumTolerance() }
    
    /// This scheduler’s definition of the current moment in time.
    public var now: SchedulerTimeType { self._now() }
    
    /// Creates a type-erasing scheduler to wrap the provided endpoints.
    ///
    /// - Parameters:
    ///   - minimumTolerance: A closure that returns the scheduler's minimum tolerance.
    ///   - now: A closure that returns the scheduler's current time.
    ///   - scheduleImmediately: A closure that schedules a unit of work to be run as soon as possible.
    ///   - delayed: A closure that schedules a unit of work to be run after a delay.
    ///   - interval: A closure that schedules a unit of work to be performed on a repeating interval.
    public init(
        minimumTolerance: @escaping () -> SchedulerTimeType.Stride,
        now: @escaping () -> SchedulerTimeType,
        scheduleImmediately: @escaping (SchedulerOptions?, @escaping () -> Void) -> Void,
        delayed: @escaping (
            SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void
        ) -> Void,
        interval: @escaping (
            SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?,
            @escaping () -> Void
        ) -> Cancellable
    ) {
        self._minimumTolerance = minimumTolerance
        self._now = now
        self._scheduleOptionsAction = scheduleImmediately
        self._scheduleAfterToleranceOptionsAction = delayed
        self._scheduleAfterIntervalToleranceOptionsAction = interval
    }
    
    /// Creates a type-erasing scheduler to wrap the provided scheduler.
    ///
    /// - Parameters:
    ///   - scheduler: A scheduler to wrap with a type-eraser.
    public init<S>(_ scheduler: S) where S: Scheduler, S.SchedulerTimeType == SchedulerTimeType, S.SchedulerOptions == SchedulerOptions {
    self._now = { scheduler.now }
    self._minimumTolerance = { scheduler.minimumTolerance }
    self._scheduleAfterToleranceOptionsAction = scheduler.schedule
    self._scheduleAfterIntervalToleranceOptionsAction = scheduler.schedule
    self._scheduleOptionsAction = scheduler.schedule
}
    
    /// Performs the action at some time after the specified date.
    public func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        self._scheduleAfterToleranceOptionsAction(date, tolerance, options, action)
    }
    
    /// Performs the action at some time after the specified date, at the
    /// specified frequency, taking into account tolerance if possible.
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        self._scheduleAfterIntervalToleranceOptionsAction(
            date, interval, tolerance, options, action)
    }
    
    /// Performs the action at the next possible opportunity.
    public func schedule(
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        self._scheduleOptionsAction(options, action)
    }
}

/// A convenience type to specify an `AnyScheduler` by the scheduler it wraps rather than by the
/// time type and options type.

public typealias AnySchedulerOf<Scheduler> = AnyScheduler<Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions> where Scheduler: Combine.Scheduler

extension Scheduler {
    /// Wraps this scheduler with a type eraser.
    public func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        AnyScheduler(self)
    }
}

extension AnyScheduler where SchedulerTimeType == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    /// A type-erased main dispatch queue.
    public static var main: Self {
        DispatchQueue.main.eraseToAnyScheduler()
    }
    
    public static var global: Self {
        DispatchQueue.global().eraseToAnyScheduler()
    }
}
