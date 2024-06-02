import Foundation

extension Action {
    public typealias ValueUpdater = @MainActor (Float) -> Void
    public typealias ValueTransformer = @Sendable (Float) -> Float

    public protocol GeometryTarget: AnyObject, Sendable {
        @MainActor
        var geometry: Node.Geometry { get set }
    }

    public protocol ColorTarget: AnyObject, Sendable {
        @MainActor
        var color: Color { get set }
    }
}

extension Node: Action.GeometryTarget {}
extension Node.Content: Action.ColorTarget {}

extension Action {
    public struct Translation {
        public var group: ActionGroup?
        public weak var target: (any GeometryTarget)?
        public var beginPosition: Point
        public var endPosition: Point
        public var duration: Duration
        public var loop: Loop
        public var valueTransformer: ValueTransformer
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            group: ActionGroup? = nil, target: any GeometryTarget, beginPosition: Point,
            endPosition: Point,
            duration: Duration = .seconds(0.3), loop: Loop = .count(1),
            valueTransformer: @escaping ValueTransformer = { $0 }, beginTime: Date = .now,
            delay: Duration = .zero, completion: @escaping Completion = {}
        ) {
            self.group = group
            self.target = target
            self.beginPosition = beginPosition
            self.endPosition = endPosition
            self.duration = duration
            self.loop = loop
            self.valueTransformer = valueTransformer
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }
    }
}

extension Action.Translation: ActionProvidable {
    public var action: Action {
        .Continuous(
            duration: duration, loop: loop,
            valueUpdater: { [weak target] value in
                guard let target else { return }
                target.geometry.position = .init(
                    simd2: (endPosition - beginPosition).simd2 * value
                        + beginPosition.simd2)
            },
            valueTransformer: valueTransformer, group: group, beginTime: beginTime,
            delay: delay,
            completion: completion
        ).action
    }
}

extension Action {
    public struct Rotation {
        public var group: ActionGroup?
        public weak var target: (any GeometryTarget)?
        public var beginAngle: Angle
        public var endAngle: Angle
        public var isShortest: Bool
        public var duration: Duration
        public var loop: Loop
        public var valueTransformer: ValueTransformer
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            group: ActionGroup? = nil, target: any GeometryTarget, beginAngle: Angle = .zero,
            endAngle: Angle = .zero,
            isShortest: Bool = false, duration: Duration = .seconds(0.3),
            loop: Loop = .count(1),
            valueTransformer: @escaping ValueTransformer = { $0 }, beginTime: Date = .now,
            delay: Duration = .zero, completion: @escaping Completion = {}
        ) {
            self.group = group
            self.target = target
            self.beginAngle = beginAngle
            self.endAngle = endAngle
            self.isShortest = isShortest
            self.duration = duration
            self.loop = loop
            self.valueTransformer = valueTransformer
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }
    }
}

extension Action.Rotation: ActionProvidable {
    public var action: Action {
        .Continuous(
            duration: duration, loop: loop,
            valueUpdater: { [weak target] value in
                guard let target else { return }
                var beginAngle = beginAngle
                if isShortest {
                    beginAngle = beginAngle.shortest(from: endAngle)
                }
                target.geometry.angle = (endAngle - beginAngle) * value + beginAngle
            }, valueTransformer: valueTransformer,
            group: group, beginTime: beginTime, delay: delay, completion: completion
        ).action
    }
}

extension Action {
    public struct Scaling {
        public var group: ActionGroup?
        public weak var target: (any GeometryTarget)?
        public var beginScale: Size
        public var endScale: Size
        public var duration: Duration
        public var loop: Loop
        public var valueTransformer: ValueTransformer
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            group: ActionGroup? = nil, target: any GeometryTarget, beginScale: Size = .one,
            endScale: Size = .one,
            duration: Duration = .seconds(0.3), loop: Loop = .count(1),
            valueTransformer: @escaping ValueTransformer = { $0 }, beginTime: Date = .now,
            delay: Duration = .zero, completion: @escaping Completion = {}
        ) {
            self.group = group
            self.target = target
            self.beginScale = beginScale
            self.endScale = endScale
            self.duration = duration
            self.loop = loop
            self.valueTransformer = valueTransformer
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }
    }
}

extension Action.Scaling: ActionProvidable {
    public var action: Action {
        .Continuous(
            duration: duration, loop: loop,
            valueUpdater: { [weak target] value in
                guard let target else { return }
                target.geometry.scale = (endScale - beginScale) * value + beginScale
            },
            valueTransformer: valueTransformer, group: group, beginTime: beginTime,
            delay: delay,
            completion: completion
        ).action
    }
}

extension Action {
    public struct Coloring: ActionProvidable {
        public var group: ActionGroup?
        public weak var target: (any ColorTarget)?
        public var beginColor: Color
        public var endColor: Color
        public var duration: Duration
        public var loop: Loop
        public var valueTransformer: ValueTransformer
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            group: ActionGroup? = nil, target: any ColorTarget,
            beginColor: Color = .init(repeating: 1.0),
            endColor: Color = .init(repeating: 1.0),
            duration: Duration = .seconds(0.3), loop: Loop = .count(1),
            valueTransformer: @escaping ValueTransformer = { $0 }, beginTime: Date = .now,
            delay: Duration = .zero, completion: @escaping Completion = {}
        ) {
            self.group = group
            self.target = target
            self.beginColor = beginColor
            self.endColor = endColor
            self.duration = duration
            self.loop = loop
            self.valueTransformer = valueTransformer
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }

        public var action: Action {
            .Continuous(
                duration: duration, loop: loop,
                valueUpdater: { [weak target] value in
                    guard let target else { return }
                    target.color = .init(
                        simd4: (endColor.simd4 - beginColor.simd4) * value + beginColor.simd4)
                },
                valueTransformer: valueTransformer, group: group, beginTime: beginTime,
                delay: delay,
                completion: completion
            ).action
        }
    }
}

extension Action {
    public struct Fading: ActionProvidable {
        public var group: ActionGroup?
        public weak var target: (any ColorTarget)?
        public var beginAlpha: Alpha
        public var endAlpha: Alpha
        public var duration: Duration
        public var loop: Loop
        public var valueTransformer: ValueTransformer
        public var beginTime: Date
        public var delay: Duration
        public var completion: Completion

        public init(
            group: ActionGroup? = nil, target: any ColorTarget, beginAlpha: Alpha = .one,
            endAlpha: Alpha = .one,
            duration: Duration = .seconds(0.3), loop: Loop = .count(1),
            valueTransformer: @escaping ValueTransformer = { $0 }, beginTime: Date = .now,
            delay: Duration = .zero, completion: @escaping Completion = {}
        ) {
            self.group = group
            self.target = target
            self.beginAlpha = beginAlpha
            self.endAlpha = endAlpha
            self.duration = duration
            self.loop = loop
            self.valueTransformer = valueTransformer
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }

        public var action: Action {
            .Continuous(
                duration: duration, loop: loop,
                valueUpdater: { [weak target] value in
                    guard let target else { return }
                    target.color.alpha = .init(
                        value: beginAlpha.value + (endAlpha.value - beginAlpha.value) * value)
                },
                valueTransformer: valueTransformer, group: group, beginTime: beginTime,
                delay: delay,
                completion: completion
            ).action
        }
    }
}
