import BrassBand
import Foundation

@MainActor
final class BigButtonText {
    let strings: Strings

    var node: Node { strings.rectPlane.node }

    private var cancellables: Set<AnyCancellable> = []

    init(fontAtlas: FontAtlas) {
        strings = .init(text: "-----", fontAtlas: fontAtlas, maxWordCount: 32, alignment: .mid)

        strings.actualFrameLayoutSource.layoutRegionPublisher.sink { [weak strings] region in
            strings?.rectPlane.node.geometry.position.y = -region.center.y
        }.store(in: &cancellables)
    }

    func setStatus(_ status: Button.Phase) {
        strings.text = String(describing: status)
    }
}
