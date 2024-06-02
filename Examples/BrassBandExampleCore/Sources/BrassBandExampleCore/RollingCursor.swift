import BrassBand
import Foundation

@MainActor
final class RollingCursor {
    let node: Node = .init()
    private var cancellables: Set<AnyCancellable> = []

    init(eventInput: EventInput, rootAction: ParallelAction) {
        setupNode()
        observeEvent(eventInput: eventInput, rootAction: rootAction)

        rootAction.insert(makeRotateAction(node))
    }

    private func setupNode() {
        let count = 5
        let angleDiff = 360.0 / Float(count)
        let plane = RectPlane(rectCount: count)

        let region = Region(center: .zero, size: .init(width: 1.0, height: 1.0))
        let translation = simd_float4x4.translation(x: 0.0, y: 1.6)

        for index in 0..<count {
            let rotation = simd_float4x4.rotation(angle: .init(degrees: angleDiff * Float(index)))
            plane.data.setRectPosition(region, rectIndex: index, matrix: rotation * translation)
        }

        plane.content.color = .init(red: 0.0, green: 0.6, blue: 1.0, alpha: 0.0)

        node.appendSubNode(plane.node)
    }

    private func observeEvent(eventInput: EventInput, rootAction: ParallelAction) {
        class LastAction {
            var id: ActionId?
        }
        eventInput.cursorPublisher.sink { [weak self, lastAction = LastAction()] cursor in
            guard let node = self?.node else { return }
            guard let position = node.parent?.convertPosition(cursor.position) else { return }

            node.geometry.position = position

            let makeFadeAction = { (target: Node.Content, alpha: Alpha) in
                Action.Fading(
                    target: target, beginAlpha: target.color.alpha,
                    endAlpha: alpha,
                    duration: .seconds(0.5)
                )
            }

            for childNode in node.subNodes {
                switch cursor.phase {
                case .began:
                    if let lastActionId = lastAction.id {
                        rootAction.remove(for: lastActionId)
                    }
                    let target = childNode.content!
                    let action = makeFadeAction(target, .one)
                    lastAction.id = rootAction.insert(action)
                case .ended:
                    if let lastActionId = lastAction.id {
                        rootAction.remove(for: lastActionId)
                    }
                    let target = childNode.content!
                    let action = makeFadeAction(target, .zero)
                    lastAction.id = rootAction.insert(action)
                case .changed:
                    break
                }
            }
        }.store(in: &cancellables)
    }
}

private func makeRotateAction(_ target: Node) -> Action {
    let rotateAction = Action.Rotation(
        target: target, endAngle: .init(degrees: -360.0), duration: .seconds(2), loop: .infinity
    )
    let scaleAction = Action.Scaling(
        target: target, beginScale: .init(repeating: 10.0), endScale: .init(repeating: 15.0),
        duration: .seconds(5), loop: .infinity,
        valueTransformer: [Transformer.pingPong, Transformer.easeInOutSine].connected
    )
    return ParallelAction(actions: [rotateAction, scaleAction]).rawAction
}
