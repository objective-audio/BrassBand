import BrassBand
import Foundation

@MainActor
final class BigButton {
    let button: Button

    var node: Node { button.rectPlane.node }

    private var cancellables: Set<AnyCancellable> = []

    static private let radius: Float = 60.0

    init(eventInput: EventInput, detector: Detector, renderer: Renderer, texture: Texture) {
        button = .init(
            region: .init(center: .zero, size: .init(repeating: Self.radius * 2.0)),
            eventInput: eventInput, detector: detector, renderer: renderer, stateCount: 1)

        button.rectPlane.node.colliders = [
            .init(shape: CircleShape(center: .zero, radius: Self.radius))
        ]

        button.setCanBeginTracking {
            switch $0.touchId {
            case .touch:
                return true
            case .mouse:
                return $0.touchId == .mouseLeft || $0.touchId == .mouseRight
            }
        }

        button.setCanIndicateTracking {
            switch $0.touchId {
            case .touch:
                return true
            case .mouse:
                return $0.touchId == .mouseLeft
            }
        }

        setTexture(texture)
    }

    func setTexture(_ texture: Texture) {
        cancellables.removeAll()

        let data = button.rectPlane.data

        button.rectPlane.content.meshes.first?.texture = texture

        let width = UInt32(Self.radius * 2)
        let imageSize = UIntSize(repeating: width)

        let element0 = texture.addElement(size: imageSize) {
            $0.setFillColor(gray: 0.3, alpha: 1.0)
            $0.fillEllipse(
                in: .init(
                    origin: .zero,
                    size: .init(width: CGFloat(imageSize.width), height: CGFloat(imageSize.height)))
            )
        }

        data.bindRectTexcoords(element: element0, rectIndex: 0).store(in: &cancellables)

        let element1 = texture.addElement(size: imageSize) {
            $0.setFillColor(Color(rgb: .red, alpha: .one).cgColor)
            $0.fillEllipse(
                in: .init(
                    origin: .zero,
                    size: .init(width: CGFloat(imageSize.width), height: CGFloat(imageSize.height)))
            )
        }

        data.bindRectTexcoords(element: element1, rectIndex: 1).store(in: &cancellables)
    }
}
