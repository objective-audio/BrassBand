import Foundation
import os

public typealias ActionId = UUID

public struct ParallelAction: Sendable {
    private let actions: Actions
    public let rawAction: Action

    public init(
        actions: [any ActionProvidable] = [],
        group: ActionGroup? = nil,
        beginTime: Date = .now,
        delay: Duration = .zero,
        completion: @escaping @MainActor () -> Void = {}
    ) {
        let actions = Actions(actions)
        self.actions = actions

        let timeUpdater: Action.TimeUpdater = { [actions] (date, _) in
            let updatings = actions.value

            for (id, updating) in updatings {
                if updating.update(date) {
                    actions.remove(for: id)
                }
            }

            return actions.value.isEmpty
        }

        rawAction = .init(
            group: group, beginTime: beginTime, delay: delay, timeUpdater: timeUpdater,
            completion: completion)
    }

    public var actionCount: Int {
        actions.count
    }

    @discardableResult
    public func insert(_ actionProvider: some ActionProvidable) -> ActionId {
        actions.insert(actionProvider.action)
    }

    public func remove(for id: ActionId) {
        actions.remove(for: id)
    }

    public func remove(for group: ActionGroup) {
        actions.remove(for: group)
    }
}

private final class Actions: @unchecked Sendable {
    private var _value: OSAllocatedUnfairLock<[ActionId: Action]>

    init(_ actionProviders: [any ActionProvidable]) {
        let actions = actionProviders.map { (ActionId(), $0.action) }
        _value = .init(initialState: actions.reduce(into: [:]) { $0[$1.0] = $1.1 })
    }

    var value: [ActionId: Action] {
        _value.withLock { $0 }
    }

    var count: Int {
        _value.withLock { $0.count }
    }

    func insert(_ action: Action) -> ActionId {
        let id = ActionId()
        _value.withLock { $0[id] = action }
        return id
    }

    func remove(for group: ActionGroup) {
        _value.withLock {
            for (id, action) in $0 {
                if action.group == group {
                    $0[id] = nil
                }
            }
        }
    }

    func remove(for id: ActionId) {
        _value.withLock {
            $0[id] = nil
        }
    }
}
