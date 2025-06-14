import Foundation

public struct Action: Sendable, Renderer.Action, ActionProvidable {
    public typealias TimeUpdater = @MainActor (Date, Action) -> Bool
    public typealias Completion = @MainActor () -> Void

    public enum Loop: Sendable, Equatable {
        case count(Int)
        case infinity
    }

    public var group: ActionGroup?
    public var beginTime: Date
    public var delay: Duration
    public var timeUpdater: TimeUpdater
    public var completion: Completion

    public init(
        group: ActionGroup? = nil,
        beginTime: Date = .now,
        delay: Duration = .zero,
        timeUpdater: @escaping TimeUpdater = { (_, _) in
            true
        },
        completion: @escaping Completion = {}
    ) {
        self.group = group
        self.beginTime = beginTime
        self.delay = delay
        self.timeUpdater = timeUpdater
        self.completion = completion
    }

    @MainActor
    public func update(_ date: Date) -> Bool {
        if date < (beginTime + TimeInterval(delay)) {
            return false
        }

        let finished = timeUpdater(date, self)

        if finished {
            completion()
        }

        return finished
    }

    func timeDifference(to date: Date) -> Double {
        return date.timeIntervalSince(beginTime) - TimeInterval(delay)
    }

    func delayed(beginTime: Date, delay: Duration) -> Self {
        .init(
            group: group, beginTime: beginTime, delay: delay, timeUpdater: timeUpdater,
            completion: completion)
    }

    public var action: Action {
        self
    }
}

extension Action {
    public struct Continuous: ActionProvidable {
        public var duration: Duration
        public var loop: Loop
        public var valueUpdater: ValueUpdater
        public var valueTransformer: Transformer
        public var group: ActionGroup?
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            duration: Duration = .seconds(0.3),
            loop: Loop = .count(1),
            valueUpdater: @escaping ValueUpdater = { _ in },
            valueTransformer: Transformer = .linear,
            group: ActionGroup? = nil,
            beginTime: Date = .now,
            delay: Duration = .zero,
            completion: @escaping Completion = {}
        ) {
            self.duration = duration
            self.loop = loop
            self.valueUpdater = valueUpdater
            self.valueTransformer = valueTransformer
            self.group = group
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }

        public var action: Action {
            .init(
                group: group,
                beginTime: beginTime,
                delay: delay,
                timeUpdater: { [duration, loop, valueTransformer, valueUpdater] (date, action) in
                    var finished = false

                    let duration = Double(duration)

                    switch loop {
                    case .count(let count):
                        if count > 0 {
                            let endTime =
                                action.beginTime + TimeInterval(action.delay) + duration
                                * TimeInterval(count)
                            if endTime <= date {
                                finished = true
                            }
                        } else {
                            finished = true
                        }
                    case .infinity:
                        break
                    }

                    var value: Float =
                        finished
                        ? 1.0 : Float(fmod(action.timeDifference(to: date), duration) / duration)

                    value = valueTransformer.transform(value)

                    valueUpdater(value)

                    return finished
                },
                completion: completion
            )
        }
    }

    public struct SequenceElement: Sendable {
        let provider: any ActionProvidable
        let duration: Duration

        public init(_ provider: any ActionProvidable, duration: Duration = .zero) {
            self.provider = provider
            self.duration = duration
        }
    }

    public struct Sequence: ActionProvidable {
        public var elements: [SequenceElement]
        public var group: ActionGroup?
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            elements: [SequenceElement],
            group: ActionGroup? = nil,
            beginTime: Date = .now,
            delay: Duration = .zero,
            completion: @escaping Completion = {}
        ) {
            self.elements = elements
            self.group = group
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }

        public var action: Action {
            var summingDelay = delay
            var actions: [Action] = []
            for element in elements {
                actions.append(
                    element.provider.action.delayed(beginTime: beginTime, delay: summingDelay)
                )
                summingDelay += element.duration
            }

            return ParallelAction(
                actions: actions, group: group, beginTime: beginTime, delay: delay,
                completion: completion
            ).rawAction
        }
    }
}
