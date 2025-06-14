import Foundation

@MainActor
public final class LayoutLinkAnimator {
    private let rootAction: ParallelAction
    private let groups: [ActionGroup]
    private var cancellables: Set<AnyCancellable>

    public init(
        rootAction: ParallelAction, layoutLinks: [any LayoutLink],
        duration: Duration = .seconds(0.3), group: ActionGroup? = nil,
        valueTransformer: Transformer = .linear,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        let layoutLinks: [LayoutValueLink] = layoutLinks.flatMap(\.layoutValueLinks)

        self.rootAction = rootAction

        var groups: [ActionGroup] = []
        var cancellables: Set<AnyCancellable> = []

        for layoutLink in layoutLinks {
            let group = ActionGroup()
            groups.append(group)

            let sourceGuide = layoutLink.source
            let destinationGuide = layoutLink.destination

            sourceGuide.valuePublisher.sink { [weak destinationGuide] value in
                guard let destinationGuide else { return }

                rootAction.remove(for: group)

                let action = Action.Layout(
                    group: group, target: destinationGuide, beginValue: destinationGuide.value,
                    endValue: value, duration: duration, valueTransformer: valueTransformer,
                    beginTime: now())

                rootAction.insert(action)
            }.store(in: &cancellables)
        }

        self.groups = groups
        self.cancellables = cancellables
    }

    deinit {
        Task { @MainActor [rootAction, groups] in
            for group in groups {
                rootAction.remove(for: group)
            }
        }
    }
}
