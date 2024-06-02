import BrassBand
import Foundation

@MainActor
final class Bg {
    private let rectPlane: RectPlane = .init(rectCount: 1)
    private let layoutGuide: LayoutRegionGuide = .init()
    private var cancellables: Set<AnyCancellable> = []

    init(viewLook: ViewLook) {
        viewLook.$appearance.sink { [weak self] appearance in
            guard let self else { return }
            switch appearance {
            case .normal:
                self.rectPlane.content.color.rgb = .init(repeating: 0.75)
            case .dark:
                self.rectPlane.content.color.rgb = .init(repeating: 0.25)
            }
        }.store(in: &cancellables)

        layoutGuide.regionPublisher.sink { [weak self] region in
            guard let self else { return }
            self.rectPlane.data.setRectPosition(region, rectIndex: 0)
        }.store(in: &cancellables)

        viewLook.safeAreaLayoutGuide.regionPublisher.sink { [weak self] region in
            guard let self else { return }
            self.layoutGuide.region = region
        }.store(in: &cancellables)
    }

    var node: Node { rectPlane.node }
}
