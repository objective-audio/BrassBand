import BrassBand
import Foundation

@MainActor
final class TouchCircle {
    private struct TouchObject {
        let node: Node
        let action: ParallelAction
        let actionId: ActionId
    }

    private let rootNode: Node = .empty

    var node: Node { rootNode }

    private let rectPlaneData: RectPlaneData = .init(rectCount: 1)
    private let rootAction: ParallelAction
    private let texture: Texture
    private var objects: [TouchId: TouchObject] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init(eventInput: EventInput, rootAction: ParallelAction, texture: Texture) {
        self.rootAction = rootAction
        self.texture = texture

        rectPlaneData.setRectPosition(.init(center: .zero, size: .one), rectIndex: 0)

        eventInput.touchPublisher.sink { [weak self] event in
            self?.updateTouchNode(event: event)
        }.store(in: &cancellables)

        let element = texture.addElement(size: .init(repeating: 100)) {
            $0.setStrokeColor(Color(rgb: .white, alpha: .one).cgColor)
            $0.setLineWidth(1.0)
            $0.strokeEllipse(in: .init(x: 2, y: 2, width: 96, height: 96))
        }

        rectPlaneData.bindRectTexcoords(element: element, rectIndex: 0).store(in: &cancellables)
    }

    private func updateTouchNode(event: TouchEvent) {
        let touchId = event.touchId

        switch event.phase {
        case .began:
            insertTouchNode(touchId: touchId)
            moveTouchNode(touchId: touchId, position: event.position)
        case .changed:
            moveTouchNode(touchId: touchId, position: event.position)
        case .ended, .canceled:
            moveTouchNode(touchId: touchId, position: event.position)
            eraseTouchNode(touchId: touchId)
        case .mayBegin, .stationary:
            break
        }
    }

    private func insertTouchNode(touchId: TouchId) {
        guard objects[touchId] == nil else {
            return
        }

        let container = Node.ContentContainer()
        let node = container.node
        let mesh = Mesh(
            vertexData: rectPlaneData.vertexData.rawMeshData,
            indexData: rectPlaneData.indexData.rawMeshData, texture: texture)

        container.content.meshes = [mesh]
        node.geometry.scale = .zero
        container.content.color.alpha = .init(value: 0.0)

        rootNode.appendSubNode(node)

        let scaleAction1 = Action.Scaling(
            target: node, beginScale: .init(repeating: 0.1), endScale: .init(repeating: 200.0),
            duration: .seconds(0.1), valueTransformer: Transformer.easeInSine
        )
        let scaleAction2 = Action.Scaling(
            target: node, beginScale: .init(repeating: 200.0), endScale: .init(repeating: 100.0),
            duration: .seconds(0.2), valueTransformer: Transformer.easeOutSine
        )
        let scaleAction = Action.Sequence(elements: [
            .init(scaleAction1, duration: .seconds(0.1)),
            .init(scaleAction2, duration: .seconds(0.2)),
        ])
        let alphaAction = Action.Fading(
            target: container.content, beginAlpha: .init(value: 0.0),
            endAlpha: .init(value: 1.0),
            duration: .seconds(0.3)
        )
        let action = ParallelAction(actions: [scaleAction, alphaAction])

        let actionId = rootAction.insert(action.rawAction)

        objects[touchId] = .init(node: node, action: action, actionId: actionId)
    }

    private func moveTouchNode(touchId: TouchId, position: Point) {
        guard let touchObject = objects[touchId] else {
            return
        }

        if let parentNode = touchObject.node.parent {
            touchObject.node.geometry.position = parentNode.convertPosition(position)
        }
    }

    private func eraseTouchNode(touchId: TouchId) {
        guard let touchObject = objects[touchId] else {
            return
        }

        rootAction.remove(for: touchObject.actionId)

        let node = touchObject.node
        let content = node.content!

        let scaleAction = Action.Scaling(
            target: node, beginScale: node.geometry.scale, endScale: .init(repeating: 300.0),
            duration: .seconds(0.3),
            valueTransformer: Transformer.easeOutSine,
            completion: {
                node.removeFromSuper()
            }
        )
        let alphaAction = Action.Fading(
            target: content, beginAlpha: content.color.alpha, endAlpha: .zero,
            duration: .seconds(0.3),
            valueTransformer: [Transformer.easeOutSine, Transformer.easeOutSine].connected
        )
        let action = ParallelAction(actions: [scaleAction, alphaAction])

        rootAction.insert(action.rawAction)

        objects[touchId] = nil
    }
}
