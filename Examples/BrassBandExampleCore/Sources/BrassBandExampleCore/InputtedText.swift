import Foundation

@MainActor
final class InputtedText {
    private let strings: Strings
    private var cancellables: Set<AnyCancellable> = []

    init(fontAtlas: FontAtlas, eventInput: EventInput, safeAreaGuide: LayoutRegionSource) {
        strings = .init(
            fontAtlas: fontAtlas,
            maxWordCount: 512,
            attributes: [
                .init(range: nil, color: .init(rgb: .white, alpha: .one)),
                .init(range: .init(index: 1, length: 2), color: .init(rgb: .blue, alpha: .one)),
            ],
            alignment: .min)
        strings.rectPlane.content.meshes.first?.isMeshColorUsed = true

        eventInput.keyPublisher.sink { [weak self] event in
            self?.updateText(event)
        }.store(in: &cancellables)

        safeAreaGuide.layoutRegionPublisher.sink { [weak self] region in
            let padding: Float = 4.0
            self?.strings.preferredFrame =
                region
                + RegionInsets(left: padding, right: -padding, bottom: padding, top: -padding)
        }.store(in: &cancellables)
    }

    var node: Node {
        strings.rectPlane.node
    }

    func appendText(_ text: String) {
        strings.text += text
    }

    private func updateText(_ event: KeyEvent) {
        guard event.phase == .began || event.phase == .changed else { return }

        let keyCode = event.keyCode

        switch keyCode {
        case 51:
            if strings.text.count > 0 {
                strings.text.removeLast()
            }
        default:
            appendText(event.characters)
        }
    }
}
