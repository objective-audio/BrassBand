import Testing

@testable import BrassBand

private final class DetectorStub: Button.Detector {
    var detectHandler: (Point, Collider) -> Bool = { (_, _) in false }

    func detect(location: BrassBand.Point, collider: BrassBand.Collider) -> Bool {
        return detectHandler(location, collider)
    }
}

private final class RendererStub: Button.Renderer {
    let willRenderSubject = PassthroughSubject<Void, Never>()
    var willRender: AnyPublisher<Void, Never> { willRenderSubject.eraseToAnyPublisher() }
}

@MainActor
struct ButtonTests {
    private let detector = DetectorStub()
    private let eventInput = EventInput()
    private let renderer = RendererStub()
    private let button: Button

    init() {
        button = Button(
            region: .init(center: .zero, size: .init(repeating: 1.0)), eventInput: eventInput,
            detector: detector, renderer: renderer, stateCount: 2)

        var renderInfo = NodeRenderInfo()
        button.rectPlane.node.buildRenderInfo(&renderInfo)

        detector.detectHandler = { location, collider in
            collider.hitTest(location)
        }
    }

    @Test func trackBeganAndEnded() {
        var contexts: [Button.Context] = []

        let canceller = button.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 0)
            #expect(indices[1] == 2)
            #expect(indices[2] == 1)
            #expect(indices[3] == 1)
            #expect(indices[4] == 2)
            #expect(indices[5] == 3)
        }

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].touch.touchId == .mouseLeft)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 4)
            #expect(indices[1] == 6)
            #expect(indices[2] == 5)
            #expect(indices[3] == 5)
            #expect(indices[4] == 6)
            #expect(indices[5] == 7)
        }

        eventInput.input(
            touchEvent: .init(phase: .ended, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .ended)
        #expect(contexts[1].touch.touchId == .mouseLeft)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 0)
            #expect(indices[1] == 2)
            #expect(indices[2] == 1)
            #expect(indices[3] == 1)
            #expect(indices[4] == 2)
            #expect(indices[5] == 3)
        }

        canceller.cancel()
    }

    @Test func trackBeganAndCanceled() {
        var contexts: [Button.Context] = []

        let canceller = button.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].touch.touchId == .mouseLeft)

        eventInput.input(
            touchEvent: .init(phase: .canceled, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .canceled)
        #expect(contexts[1].touch.touchId == .mouseLeft)

        canceller.cancel()
    }

    @Test func cancelTracking() {
        var contexts: [Button.Context] = []

        let canceller = button.publisher.sink { contexts.append($0) }

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].touch.touchId == .mouseLeft)

        button.cancelTracking()

        #expect(contexts.count == 2)
        #expect(contexts[1].phase == .canceled)
        #expect(contexts[1].touch.touchId == .mouseLeft)

        canceller.cancel()
    }

    @Test func canBeginTracking() {
        button.setCanBeginTracking {
            $0.touchId == .mouseLeft
        }

        var contexts: [Button.Context] = []

        let canceller = button.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseRight, position: .zero, timestamp: 0))

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].touch.touchId == .mouseLeft)

        canceller.cancel()
    }

    @Test func canIndicateTracking() {
        button.setCanIndicateTracking {
            $0.touchId == .mouseLeft
        }

        var contexts: [Button.Context] = []

        let canceller = button.publisher.sink { contexts.append($0) }

        #expect(contexts.count == 0)

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseRight, position: .zero, timestamp: 0))

        #expect(contexts.count == 1)
        #expect(contexts[0].phase == .began)
        #expect(contexts[0].touch.touchId == .mouseRight)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 0)
            #expect(indices[1] == 2)
            #expect(indices[2] == 1)
            #expect(indices[3] == 1)
            #expect(indices[4] == 2)
            #expect(indices[5] == 3)
        }

        button.cancelTracking()

        #expect(contexts.count == 2)

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0))

        #expect(contexts.count == 3)
        #expect(contexts[2].phase == .began)
        #expect(contexts[2].touch.touchId == .mouseLeft)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 4)
            #expect(indices[1] == 6)
            #expect(indices[2] == 5)
            #expect(indices[3] == 5)
            #expect(indices[4] == 6)
            #expect(indices[5] == 7)
        }

        canceller.cancel()
    }

    @Test func stateIndex() {
        #expect(button.stateIndex == 0)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 0)
            #expect(indices[1] == 2)
            #expect(indices[2] == 1)
            #expect(indices[3] == 1)
            #expect(indices[4] == 2)
            #expect(indices[5] == 3)
        }

        button.stateIndex = 1

        #expect(button.stateIndex == 1)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 8)
            #expect(indices[1] == 10)
            #expect(indices[2] == 9)
            #expect(indices[3] == 9)
            #expect(indices[4] == 10)
            #expect(indices[5] == 11)
        }

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0))

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 12)
            #expect(indices[1] == 14)
            #expect(indices[2] == 13)
            #expect(indices[3] == 13)
            #expect(indices[4] == 14)
            #expect(indices[5] == 15)
        }

        button.stateIndex = 0

        #expect(button.stateIndex == 0)

        button.rectPlane.data.indexData.read { indices in
            #expect(indices[0] == 4)
            #expect(indices[1] == 6)
            #expect(indices[2] == 5)
            #expect(indices[3] == 5)
            #expect(indices[4] == 6)
            #expect(indices[5] == 7)
        }
    }

    @Test func texture() {
        let provider = ScaleFactorProviderStub()
        let texture = Texture(pointSize: .one, scaleFactorProvider: provider)

        #expect(button.texture == nil)

        button.texture = texture

        #expect(button.texture === texture)
    }
}
