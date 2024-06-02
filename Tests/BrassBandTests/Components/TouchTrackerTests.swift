import Testing

@testable import BrassBand

private final class DetectorStub: TouchTracker.Detector {
    var detectHandler: (Point, Collider) -> Bool = { (_, _) in false }

    func detect(location: BrassBand.Point, collider: BrassBand.Collider) -> Bool {
        return detectHandler(location, collider)
    }
}

private final class RendererStub: TouchTracker.Renderer {
    let willRenderSubject = PassthroughSubject<Void, Never>()
    var willRender: AnyPublisher<Void, Never> { willRenderSubject.eraseToAnyPublisher() }
}

@MainActor
struct TouchTrackerTests {
    private let detector = DetectorStub()
    private let eventInput = EventInput()
    private let renderer = RendererStub()
    private let node = Node.content
    private let colliders: [Collider] = [
        .init(
            shape: RectShape(
                rect: .init(center: .init(x: -0.5, y: 0.0), size: .init(repeating: 0.9)))),
        .init(
            shape: RectShape(
                rect: .init(center: .init(x: 0.5, y: 0.0), size: .init(repeating: 0.9)))),
    ]

    init() {
        node.colliders = colliders

        var renderInfo = NodeRenderInfo()
        node.buildRenderInfo(&renderInfo)

        detector.detectHandler = { location, collider in
            collider.hitTest(location)
        }
    }

    @Test func trackEventsSingleId() async throws {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])

        eventInput.input(
            touchEvent: .init(
                phase: .mayBegin, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0),
                timestamp: 0))

        #expect(contexts.count == 1)

        eventInput.input(
            touchEvent: .init(
                phase: .changed, touchId: .mouseLeft, position: .init(x: -0.4, y: 0.0), timestamp: 0
            ))

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .moved)
        #expect(contexts[1].colliderIndex == 0)
        #expect(contexts[1].collider === colliders[0])

        eventInput.input(
            touchEvent: .init(phase: .changed, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 3)
        #expect(contexts[2].phase == .leaved)
        #expect(contexts[2].colliderIndex == 0)
        #expect(contexts[2].collider === colliders[0])

        eventInput.input(
            touchEvent: .init(
                phase: .changed, touchId: .mouseLeft, position: .init(x: 0.5, y: 0.0), timestamp: 0)
        )

        #expect(contexts.count == 4)
        #expect(contexts[3].phase == .entered)
        #expect(contexts[3].colliderIndex == 1)
        #expect(contexts[3].collider === colliders[1])

        eventInput.input(
            touchEvent: .init(
                phase: .ended, touchId: .mouseLeft, position: .init(x: 0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 5)
        #expect(contexts[4].phase == .ended)
        #expect(contexts[4].colliderIndex == 1)
        #expect(contexts[4].collider === colliders[1])

        eventInput.input(
            touchEvent: .init(
                phase: .ended, touchId: .mouseLeft, position: .init(x: 0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 5)

        canceller.cancel()
    }

    @Test func trackBeganDifferentId() async throws {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])
        #expect(contexts[0].touchEvent.touchId == .mouseLeft)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseRight, position: .init(x: -0.5, y: 0.0), timestamp: 0)
        )

        #expect(contexts.count == 1)

        canceller.cancel()
    }

    @Test func trackBeganTwice() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.4, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)

        canceller.cancel()
    }

    @Test func cancelTracking() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])

        tracker.cancelTracking()

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .canceled)
        #expect(contexts[1].colliderIndex == 0)
        #expect(contexts[1].collider === colliders[0])

        canceller.cancel()
    }

    @Test func cancelByCollidersChanged() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])

        node.colliders = []

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .canceled)
        #expect(contexts[1].colliderIndex == 0)
        #expect(contexts[1].collider == nil)

        canceller.cancel()
    }

    @Test func cancelByNodeDisabled() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])

        node.isEnabled = false

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .canceled)
        #expect(contexts[1].colliderIndex == 0)
        #expect(contexts[1].collider === colliders[0])

        canceller.cancel()
    }

    @Test func cancelByTouchCanceled() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)
        #expect(contexts[0].collider === colliders[0])

        eventInput.input(
            touchEvent: .init(
                phase: .canceled, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0),
                timestamp: 0))

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .canceled)
        #expect(contexts[1].colliderIndex == 0)
        #expect(contexts[1].collider === colliders[0])

        canceller.cancel()
    }

    @Test func leaveByWillNodeMoved() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].colliderIndex == 0)

        renderer.willRenderSubject.send()

        #expect(contexts.count == 1)

        node.geometry.position = .init(x: 1.0, y: 0.0)
        var renderInfo = NodeRenderInfo()
        node.buildRenderInfo(&renderInfo)
        renderer.willRenderSubject.send()

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .leaved)
        #expect(contexts[1].colliderIndex == 0)

        canceller.cancel()
    }

    @Test func canBeginTracking() {
        let tracker = TouchTracker(
            detector: detector, eventInput: eventInput, renderer: renderer, node: node)

        tracker.canBeginTracking = { event in
            event.touchId == .mouseRight
        }

        var contexts: [TouchTracker.Context] = []

        let canceller = tracker.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseLeft, position: .init(x: -0.5, y: 0.0), timestamp: 0))

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(
                phase: .began, touchId: .mouseRight, position: .init(x: -0.5, y: 0.0), timestamp: 0)
        )

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].touchEvent.touchId == .mouseRight)
        #expect(contexts[0].colliderIndex == 0)

        canceller.cancel()
    }
}
