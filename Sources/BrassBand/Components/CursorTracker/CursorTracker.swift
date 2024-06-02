import Foundation

@MainActor
public final class CursorTracker {
    public enum Phase: Sendable {
        case entered, moved, leaved
    }

    public struct Context: Sendable {
        public let phase: Phase
        public let cursorEvent: CursorEvent
        public let colliderIndex: Int
        public let collider: Collider?
    }

    public struct TrackingValue: Sendable {
        let cursorEvent: CursorEvent
        let colliderIndex: Int
    }

    public var publisher: AnyPublisher<Context, Never> { subject.eraseToAnyPublisher() }
    public private(set) var tracking: TrackingValue?

    private weak var detector: (any Detector)?
    private weak var node: Node?
    private let subject: PassthroughSubject<Context, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []

    convenience public init(components: Components, node: Node) {
        self.init(
            detector: components.detector, eventInput: components.eventInput,
            renderer: components.renderer, node: node)
    }

    public init(
        detector: some Detector, eventInput: some EventInput, renderer: some Renderer, node: Node
    ) {
        self.detector = detector
        self.node = node

        eventInput.cursorPublisher.sink { [weak self] event in
            self?.updateTracking(event)
        }.store(in: &cancellables)

        renderer.willRender.sink { [weak self] _ in
            guard let self, let tracking = self.tracking else { return }
            self.leaveOrEnterOrMoveTracking(cursorEvent: tracking.cursorEvent, needsMove: false)
        }.store(in: &cancellables)

        node.collidersPublisher.dropFirst().sink { [weak self] _ in
            self?.cancelTracking()
        }.store(in: &cancellables)

        node.isEnabledPublisher.dropFirst().sink { [weak self] isEnabled in
            if !isEnabled {
                self?.cancelTracking()
            }
        }.store(in: &cancellables)
    }

    public func cancelTracking() {
        guard let tracking else { return }
        cancelTracking(cursorEvent: tracking.cursorEvent)
    }

    private var colliders: [Collider] {
        node?.colliders ?? []
    }

    private func updateTracking(_ cursorEvent: CursorEvent) {
        guard let detector else { return }

        switch cursorEvent.phase {
        case .began:
            guard tracking == nil else { return }

            for (index, collider) in colliders.enumerated() {
                if detector.detect(location: cursorEvent.position, collider: collider) {
                    tracking = .init(cursorEvent: cursorEvent, colliderIndex: index)
                    notify(phase: .entered, cursorEvent: cursorEvent, colliderIndex: index)
                }
            }
        case .changed:
            leaveOrEnterOrMoveTracking(cursorEvent: cursorEvent, needsMove: true)
        case .ended:
            guard isTracking(cursorEvent: cursorEvent, colliderIndex: nil), let tracking else {
                return
            }
            self.tracking = nil
            notify(
                phase: .leaved, cursorEvent: tracking.cursorEvent,
                colliderIndex: tracking.colliderIndex)
        }
    }

    private func leaveOrEnterOrMoveTracking(cursorEvent: CursorEvent, needsMove: Bool) {
        guard let detector else { return }

        for (index, collider) in colliders.enumerated() {
            let isEventTracking = isTracking(cursorEvent: cursorEvent, colliderIndex: index)
            let isDetected = detector.detect(location: cursorEvent.position, collider: collider)

            if !isEventTracking && isDetected {
                tracking = .init(cursorEvent: cursorEvent, colliderIndex: index)
                notify(phase: .entered, cursorEvent: cursorEvent, colliderIndex: index)
            } else if isEventTracking && !isDetected {
                tracking = nil
                notify(phase: .leaved, cursorEvent: cursorEvent, colliderIndex: index)
            } else if isEventTracking && needsMove {
                notify(phase: .moved, cursorEvent: cursorEvent, colliderIndex: index)
            }
        }
    }

    private func cancelTracking(cursorEvent: CursorEvent) {
        guard let tracking, tracking.cursorEvent.isEqual(toEvent: cursorEvent) else { return }
        self.tracking = nil
        notify(
            phase: .leaved, cursorEvent: tracking.cursorEvent, colliderIndex: tracking.colliderIndex
        )
    }

    private func notify(phase: Phase, cursorEvent: CursorEvent, colliderIndex: Int) {
        let colliders = self.colliders
        let collider = (colliderIndex < colliders.count) ? colliders[colliderIndex] : nil
        subject.send(
            .init(
                phase: phase, cursorEvent: cursorEvent, colliderIndex: colliderIndex,
                collider: collider))
    }

    private func isTracking(cursorEvent: CursorEvent, colliderIndex: Int?) -> Bool {
        guard let tracking else { return false }

        // colliderIndexが指定されていれば、一致していた場合のみ判定する
        if let colliderIndex, colliderIndex != tracking.colliderIndex {
            return false
        }

        return cursorEvent.isEqual(toEvent: tracking.cursorEvent)
    }
}
