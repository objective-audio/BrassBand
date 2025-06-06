import BrassBand
import Foundation

@MainActor
final class HoverPlanes {
    let node: Node
    private let trackers: [CursorTracker]
    private var cancellables: Set<AnyCancellable>

    init(components: Components) {
        let nodeCount: Int = 16
        let rootNode = Node.empty
        let rootAction = components.rootAction

        node = rootNode

        var trackers: [CursorTracker] = []
        var cancellables: Set<AnyCancellable> = []

        for index in (0..<nodeCount) {
            let plane = RectPlane(rectCount: 1)
            plane.data.setRectPosition(.init(center: .zero, size: .one), rectIndex: 0)

            let node = plane.node
            node.geometry.position = .init(x: 100.0, y: 0.0)
            node.geometry.scale = .init(width: 10.0, height: 30.0)
            plane.content.color.rgb = .init(repeating: 0.3)
            node.colliders = [
                .init(shape: RectShape(rect: .init(center: .zero, size: .one)))
            ]

            let handleNode = Node.empty
            handleNode.appendSubNode(node)
            handleNode.geometry.angle = .init(degrees: 360.0 / Float(nodeCount) * Float(index))

            rootNode.appendSubNode(handleNode)

            let group = ActionGroup()
            let tracker = CursorTracker(components: components, node: node)

            tracker.publisher.sink { [weak node] context in
                guard let node else { return }
                let content = node.content!

                let makeColorAction = { (color: RgbColor) in
                    let beginColor = content.color.rgb
                    return Action.Coloring(
                        group: group, target: content,
                        beginColor: .init(rgb: beginColor, alpha: .one),
                        endColor: .init(rgb: color, alpha: .one)
                    )
                }

                switch context.phase {
                case .entered:
                    rootAction.remove(for: group)
                    rootAction.insert(makeColorAction(.init(red: 1.0, green: 0.6, blue: 0.0)))
                    break
                case .leaved:
                    rootAction.remove(for: group)
                    rootAction.insert(makeColorAction(.init(repeating: 0.3)))
                    break
                case .moved:
                    break
                }
            }.store(in: &cancellables)

            trackers.append(tracker)
        }

        self.trackers = trackers
        self.cancellables = cancellables
    }
}
