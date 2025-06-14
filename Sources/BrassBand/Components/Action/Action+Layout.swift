import Foundation

extension Action {
    struct Layout {
        var group: ActionGroup?
        var target: any LayoutValueTarget
        var beginValue: Float
        var endValue: Float
        var duration: Duration
        var loop: Loop
        var valueTransformer: Transformer
        var beginTime: Date
        var delay: Duration
        var completion: Completion

        init(
            group: ActionGroup? = nil, target: any LayoutValueTarget, beginValue: Float,
            endValue: Float,
            duration: Duration = .seconds(0.3), loop: Loop = .count(1),
            valueTransformer: Transformer = .linear, beginTime: Date = .now,
            delay: Duration = .zero, completion: @escaping Completion = {}
        ) {
            self.group = group
            self.target = target
            self.beginValue = beginValue
            self.endValue = endValue
            self.duration = duration
            self.loop = loop
            self.valueTransformer = valueTransformer
            self.beginTime = beginTime
            self.delay = delay
            self.completion = completion
        }
    }
}

extension Action.Layout: ActionProvidable {
    var action: Action {
        .Continuous(
            duration: duration, loop: loop,
            valueUpdater: { [weak target] value in
                target?.setLayoutValue((endValue - beginValue) * value + beginValue)

            }, valueTransformer: valueTransformer, group: group,
            beginTime: beginTime, delay: delay, completion: completion
        ).action
    }
}
