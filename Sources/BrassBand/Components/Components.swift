import Foundation

@MainActor
public struct Components {
    public let viewLook: ViewLook
    public let system: MetalSystem
    public let rootNode: Node
    public let detector: Detector
    public let eventInput: EventInput
    public let rootAction: ParallelAction
    public let renderer: Renderer

    public init(viewLook: ViewLook, system: MetalSystem) {
        self.viewLook = viewLook
        self.system = system

        rootNode = .init(parent: viewLook)
        detector = .init()
        eventInput = .init()
        rootAction = .init()
        renderer = .init(
            rootNode: rootNode, viewLook: viewLook, system: system, detector: detector,
            action: rootAction.rawAction)
    }
}
