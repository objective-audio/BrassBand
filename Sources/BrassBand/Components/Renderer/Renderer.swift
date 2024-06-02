import Combine
import Foundation

@MainActor
public final class Renderer {
    private let rootNode: Node
    private let viewLook: any ViewLook
    private let system: any System
    private let detector: any Renderer.Detector
    private let action: any Renderer.Action
    private let willRenderSubject: PassthroughSubject<Void, Never> = .init()
    private let backgroundColorSubject: PassthroughSubject<Color, Never> = .init()
    private let didRenderSubject: PassthroughSubject<Void, Never> = .init()

    public var backgroundColor: AnyPublisher<Color, Never> {
        backgroundColorSubject.eraseToAnyPublisher()
    }

    public var willRender: AnyPublisher<Void, Never> {
        willRenderSubject.eraseToAnyPublisher()
    }

    public var didRender: AnyPublisher<Void, Never> {
        didRenderSubject.eraseToAnyPublisher()
    }

    public init(
        rootNode: Node, viewLook: some ViewLook, system: some System,
        detector: some Renderer.Detector,
        action: some Renderer.Action
    ) {
        self.rootNode = rootNode
        self.viewLook = viewLook
        self.system = system
        self.detector = detector
        self.action = action
    }

    func viewRender() {
        willRenderSubject.send(())

        if preRender() {
            backgroundColorSubject.send(viewLook.background.color)

            system.viewRender(
                projectionMatrix: viewLook.projectionMatrix, rootNode: rootNode, detector: detector)
        }

        postRender()

        didRenderSubject.send(())
    }
}

extension Renderer {
    func preRender() -> Bool {
        _ = action.update(.now)

        var treeUpdates = TreeUpdates()
        rootNode.fetchUpdates(&treeUpdates)
        viewLook.background.fetchUpdates(&treeUpdates)

        if treeUpdates.isColliderUpdated {
            detector.beginUpdate()
        }

        return treeUpdates.isAnyUpdated
    }

    func postRender() {
        rootNode.clearUpdates()
        viewLook.background.clearUpdates()
        detector.endUpdate()
    }
}
