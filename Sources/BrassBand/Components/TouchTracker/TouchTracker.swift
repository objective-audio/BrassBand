import Foundation

@MainActor
public final class TouchTracker {
    public enum Phase: Sendable {
        case began, entered, moved, leaved, ended, canceled
    }

    public struct Context: Sendable {
        public let phase: Phase
        public let touchEvent: TouchEvent
        public let colliderIndex: Int
        public let collider: Collider?
    }

    public struct TrackingValue: Sendable {
        let touchEvent: TouchEvent
        let colliderIndex: Int
    }

    public var canBeginTracking: ((TouchEvent) -> Bool)?
    public private(set) var tracking: TrackingValue?
    public var publisher: AnyPublisher<Context, Never> { subject.eraseToAnyPublisher() }

    private weak var detector: (any Detector)?
    private weak var node: (any TouchTracker.Node)?
    private let subject: PassthroughSubject<Context, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []

    convenience public init(components: Components, node: some Node) {
        self.init(
            detector: components.detector, eventInput: components.eventInput,
            renderer: components.renderer, node: node)
    }

    public init(
        detector: some Detector, eventInput: some EventInput, renderer: some Renderer,
        node: some Node
    ) {
        self.detector = detector
        self.node = node

        eventInput.touchPublisher.sink { [weak self] touchEvent in
            guard let self else { return }
            self.updateTracking(touchEvent: touchEvent)
        }.store(in: &cancellables)

        renderer.willRender.sink { [weak self] _ in
            guard let self, let tracking = self.tracking else { return }
            leaveOrEnterOrMoveTracking(
                touchEvent: tracking.touchEvent, needsMove: false)
        }.store(in: &cancellables)

        node.collidersPublisher.sink { [weak self] _ in
            self?.cancelTracking()
        }.store(in: &cancellables)

        node.isEnabledPublisher.sink { [weak self] value in
            guard !value, let self else { return }
            self.cancelTracking()
        }.store(in: &cancellables)
    }

    func cancelTracking() {
        guard let tracking else { return }
        cancelTracking(touchEvent: tracking.touchEvent)
    }
}

extension TouchTracker {
    private var colliders: [Collider] {
        node?.colliders ?? []
    }

    private func updateTracking(touchEvent: TouchEvent) {
        guard let detector else { return }

        switch touchEvent.phase {
        case .began:
            guard tracking == nil else { return }

            for (index, collider) in colliders.enumerated() {
                guard detector.detect(location: touchEvent.position, collider: collider),
                    canBeginTracking(touchEvent: touchEvent)
                else {
                    continue
                }
                tracking = .init(touchEvent: touchEvent, colliderIndex: index)
                notify(phase: .began, touchEvent: touchEvent, colliderIndex: index)
            }
        case .stationary, .changed:
            leaveOrEnterOrMoveTracking(touchEvent: touchEvent, needsMove: true)
        case .ended:
            guard isTracking(touchEvent: touchEvent, colliderIndex: nil), let tracking
            else { return }
            self.tracking = nil
            notify(
                phase: .ended, touchEvent: touchEvent,
                colliderIndex: tracking.colliderIndex)
        case .canceled:
            cancelTracking(touchEvent: touchEvent)
        case .mayBegin:
            break
        }
    }

    private func leaveOrEnterOrMoveTracking(touchEvent: TouchEvent, needsMove: Bool) {
        guard let detector else { return }

        for (index, collider) in colliders.enumerated() {
            let isEventTracking = isTracking(touchEvent: touchEvent, colliderIndex: index)
            let isDetected = detector.detect(location: touchEvent.position, collider: collider)

            if !isEventTracking, isDetected, canBeginTracking(touchEvent: touchEvent) {
                tracking = .init(touchEvent: touchEvent, colliderIndex: index)
                notify(phase: .entered, touchEvent: touchEvent, colliderIndex: index)
            } else if isEventTracking, !isDetected {
                tracking = nil
                notify(phase: .leaved, touchEvent: touchEvent, colliderIndex: index)
            } else if isEventTracking, needsMove {
                notify(phase: .moved, touchEvent: touchEvent, colliderIndex: index)
            }
        }
    }

    private func cancelTracking(touchEvent: TouchEvent) {
        guard let tracking, tracking.touchEvent.touchId == touchEvent.touchId else { return }
        self.tracking = nil
        notify(
            phase: .canceled, touchEvent: touchEvent,
            colliderIndex: tracking.colliderIndex)
    }

    private func notify(phase: Phase, touchEvent: TouchEvent, colliderIndex: Int) {
        let colliders = self.colliders
        let collider = colliderIndex < colliders.count ? colliders[colliderIndex] : nil
        subject.send(
            .init(
                phase: phase, touchEvent: touchEvent, colliderIndex: colliderIndex,
                collider: collider))
    }

    private func isTracking(touchEvent: TouchEvent, colliderIndex: Int?) -> Bool {
        if let tracking {
            // colliderIndexが指定されていれば、一致していた場合のみ判定する
            guard colliderIndex == nil || colliderIndex == tracking.colliderIndex else {
                return false
            }

            return touchEvent.touchId == tracking.touchEvent.touchId
        } else {
            return false
        }
    }

    private func canBeginTracking(touchEvent: TouchEvent) -> Bool {
        if let canBeginTracking {
            // クロージャがあったらtrueを返せばトラッキング開始できる
            return canBeginTracking(touchEvent)
        } else {
            // クロージャがなければトラッキング開始できる
            return true
        }
    }
}
