import Foundation

@MainActor
final class ModifierText {
    private let strings: Strings
    private let bottomGuide: LayoutValueGuide
    private var cancellables: Set<AnyCancellable> = []

    init(
        fontAtlas: FontAtlas, eventInput: EventInput, safeAreaGuide: LayoutRegionGuide,
        bottomGuide: LayoutValueGuide
    ) {
        strings = .init(fontAtlas: fontAtlas, maxWordCount: 64, alignment: .max)
        self.bottomGuide = bottomGuide

        var flags = Set<ModifierFlag>()
        eventInput.modifierPublisher.sink { [weak self] event in
            self?.updateText(event: event, flags: &flags)
        }.store(in: &cancellables)

        safeAreaGuide.layoutHorizontalRangeSource.layoutMinValueSource.layoutValuePublisher.sink {
            [weak self]
            value in
            guard let self else { return }
            var frame = self.strings.preferredFrame
            frame.left = value + 4.0
            self.strings.preferredFrame = frame
        }.store(in: &cancellables)

        safeAreaGuide.layoutHorizontalRangeSource.layoutMaxValueSource.layoutValuePublisher.sink {
            [weak self] value in
            guard let self else { return }
            var frame = self.strings.preferredFrame
            frame.right = value - 4.0
            self.strings.preferredFrame = frame
        }.store(in: &cancellables)

        let distance = Float(fontAtlas.ascent + fontAtlas.descent)

        bottomGuide.valuePublisher.sink { [weak self] value in
            guard let self else { return }
            var frame = self.strings.preferredFrame
            frame.bottom = value + 4.0
            frame.top = frame.bottom + distance
            self.strings.preferredFrame = frame
        }.store(in: &cancellables)
    }

    var node: Node {
        strings.rectPlane.node
    }

    private func updateText(event: ModifierEvent, flags: inout Set<ModifierFlag>) {
        let flag = event.flag

        if event.phase == .began {
            flags.insert(flag)
        } else if event.phase == .ended {
            flags.remove(flag)
        }

        strings.text = flags.map { "\($0)" }.joined(separator: " + ")
    }
}
