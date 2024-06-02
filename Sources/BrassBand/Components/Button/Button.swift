import Foundation

@MainActor
public final class Button {
    public typealias Phase = TouchTracker.Phase

    public struct Context: Sendable {
        public let phase: Phase
        public let touch: TouchEvent
    }

    public let rectPlane: RectPlane
    public let layoutGuide: LayoutRegionGuide
    public let stateCount: Int

    public var stateIndex: Int = 0 {
        willSet {
            if newValue >= stateCount {
                fatalError()
            }
        }
        didSet {
            updateRectIndex()
        }
    }

    public var texture: Texture? {
        get { rectPlane.content.meshes.first?.texture }
        set { rectPlane.content.meshes.first?.texture = newValue }
    }

    public var publisher: AnyPublisher<Context, Never> {
        touchTracker.publisher.map {
            Context(phase: $0.phase, touch: $0.touchEvent)
        }.eraseToAnyPublisher()
    }

    private let touchTracker: TouchTracker
    private var canIndicateTracking: ((TouchEvent) -> Bool)?
    private var cancellables: Set<AnyCancellable> = []

    public convenience init(region: Region, components: Components, stateCount: Int) {
        self.init(
            region: region, eventInput: components.eventInput, detector: components.detector,
            renderer: components.renderer,
            stateCount: stateCount)
    }

    public init(
        region: Region, eventInput: some Button.EventInput, detector: some Button.Detector,
        renderer: some Button.Renderer,
        stateCount: Int
    ) {
        rectPlane = .init(rectCount: stateCount * 2, indexCount: 1)
        layoutGuide = .init(region)
        self.stateCount = stateCount
        touchTracker = .init(
            detector: detector, eventInput: eventInput, renderer: renderer,
            node: rectPlane.node)

        rectPlane.node.colliders = [.init()]

        layoutGuide.regionPublisher.sink { [weak self] region in
            self?.updateRectPositions(region: region)
        }.store(in: &cancellables)

        touchTracker.publisher.sink { [weak self] value in
            self?.updateRectIndex()
        }.store(in: &cancellables)
    }

    public func cancelTracking() {
        touchTracker.cancelTracking()
    }

    public func setCanBeginTracking(_ handler: ((TouchEvent) -> Bool)?) {
        touchTracker.canBeginTracking = handler
    }

    public func setCanIndicateTracking(_ handler: ((TouchEvent) -> Bool)?) {
        canIndicateTracking = handler
    }

    public static func rectIndex(stateIndex: Int, isTracking: Bool) -> Int {
        stateIndex * 2 + (isTracking ? 1 : 0)
    }
}

extension Button {
    private var isTracking: Bool {
        touchTracker.tracking != nil
    }

    private func updateRectPositions(region: Region) {
        for index in 0..<(stateCount * 2) {
            rectPlane.data.setRectPosition(region, rectIndex: index)
        }

        guard let collider = rectPlane.node.colliders.first else {
            return
        }

        if collider.shape == nil || collider.shape?.kind == .rect {
            collider.shape = RectShape(rect: region)
        }
    }

    private func updateRectIndex() {
        rectPlane.data.setRectIndices([(indexIndex: 0, vertexIndex: rectIndex)])
    }

    private var canIndicate: Bool {
        guard let canIndicateTracking else { return true }

        if let tracking = touchTracker.tracking {
            return canIndicateTracking(tracking.touchEvent)
        } else {
            return false
        }
    }

    private var rectIndex: Int {
        Self.rectIndex(stateIndex: stateIndex, isTracking: isTracking && canIndicate)
    }
}
