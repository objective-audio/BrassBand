import BrassBand
import Foundation

@MainActor
final class ExampleButton {
    private enum State: Int, CaseIterable {
        case normal
        case hovering
    }

    let button: Button
    private let textureElements: [TextureElement]
    private let cursorTracker: CursorTracker
    private var cancellables: Set<AnyCancellable> = []

    init(region: Region, components: Components, texture: Texture) {
        button = .init(region: region, components: components, stateCount: State.allCases.count)

        button.texture = texture

        let elementSize = UIntSize(
            width: UInt32(region.size.width), height: UInt32(region.size.height))
        let rectPlaneData = button.rectPlane.data

        var textureElements: [TextureElement] = []

        for state in State.allCases {
            for isTracking in [false, true] {
                let element = texture.addElement(size: elementSize) { context in
                    let color: RgbColor =
                        switch (state, isTracking) {
                        case (.normal, false):
                            .lightGray
                        case (.normal, true):
                            .darkGray
                        case (.hovering, false):
                            .white
                        case (.hovering, true):
                            .black
                        }

                    context.setFillColor(Color(rgb: color, alpha: .one).cgColor)
                    context.fill(.init(origin: .zero, size: region.size.cgSize))
                }

                rectPlaneData.bindRectTexcoords(
                    element: element,
                    rectIndex: Button.rectIndex(
                        stateIndex: state.rawValue, isTracking: isTracking)
                ).store(in: &cancellables)

                textureElements.append(element)
            }
        }

        self.textureElements = textureElements

        button.setCanBeginTracking { touchEvent in
            switch touchEvent.touchId {
            case .mouse:
                return touchEvent.touchId == .mouseLeft || touchEvent.touchId == .mouseRight
            case .touch:
                return true
            }
        }

        button.publisher.sink { context in
            switch context.phase {
            case .ended:
                print("ExampleButton ended")
            default:
                break
            }
        }.store(in: &cancellables)

        cursorTracker = .init(components: components, node: button.rectPlane.node)

        cursorTracker.publisher.sink { [weak self] context in
            guard let self else { return }

            switch context.phase {
            case .entered:
                self.button.stateIndex = State.hovering.rawValue
            case .moved:
                break
            case .leaved:
                self.button.stateIndex = State.normal.rawValue
            }
        }.store(in: &cancellables)
    }
}
