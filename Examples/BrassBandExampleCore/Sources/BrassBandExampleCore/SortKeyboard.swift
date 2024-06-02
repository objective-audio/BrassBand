import BrassBand
import Foundation

@MainActor
final class SoftKeyboard {
    let node: Node = .init()

    private let softKeys: [SoftKey]
    private let fontAtlas: FontAtlas
    private let collectionLayout: CollectionLayout

    private let keySubject: PassthroughSubject<String, Never> = .init()
    var keyPublisher: AnyPublisher<String, Never> {
        keySubject.eraseToAnyPublisher()
    }

    private let sourceCellLayoutGuides: [LayoutRegionGuide]
    private let destinationCellLayoutGuides: [LayoutRegionGuide]
    private let cellInterporator: LayoutLinkAnimator?

    private var cancellables: Set<AnyCancellable> = []

    init(
        fontAtlas: FontAtlas, eventInput: EventInput, rootAction: ParallelAction,
        detector: Detector, renderer: Renderer, safeAreaGuide: LayoutRegionSource
    ) {
        self.fontAtlas = fontAtlas

        var cancellables: Set<AnyCancellable> = []

        let keys = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let keyWidth: Float = 36.0
        let spacing: Float = 4.0
        let width: Float = keyWidth * 3.0 + spacing * 4.0

        var cellSizes: [CollectionLayout.CellSize] = []
        for key in keys {
            if key == "0" {
                cellSizes.append(.init(column: .filled, row: keyWidth))
            } else {
                cellSizes.append(.init(column: .fixed(keyWidth), row: keyWidth))
            }
        }

        collectionLayout = .init(
            frame: .init(origin: .zero, size: .init(width: width, height: 0.0)),
            preferredCellCount: keys.count, lines: [.init(cellSizes: cellSizes)],
            rowSpacing: spacing, colSpacing: spacing,
            borders: .init(top: spacing, bottom: spacing, left: spacing, right: spacing))

        var softKeys: [SoftKey] = []

        for key in keys {
            let softKey = SoftKey(
                key: key, width: keyWidth, fontAtlas: fontAtlas, eventInput: eventInput,
                rootAction: rootAction, detector: detector, renderer: renderer
            ) { [weak keySubject] in
                keySubject?.send(key)
            }

            node.appendSubNode(softKey.node)

            softKeys.append(softKey)
        }

        self.softKeys = softKeys

        Layout.constraint(safeAreaGuide, collectionLayout.preferredLayoutGuide) {
            var region = $0
            region.right = min($0.left + width, $0.right)
            return region
        }.store(in: &cancellables)

        var sourceCellLayoutGuides: [LayoutRegionGuide] = []
        var destinationCellLayoutGuides: [LayoutRegionGuide] = []
        var providers: [any LayoutLink] = []

        for softKey in softKeys {
            let sourceGuide = LayoutRegionGuide()
            let destinationGuide = LayoutRegionGuide()
            sourceCellLayoutGuides.append(sourceGuide)
            destinationCellLayoutGuides.append(destinationGuide)

            // destinationのLayoutGuideにSoftKeyの位置を合わせる
            destinationGuide.regionPublisher.sink { [weak softKey] value in
                softKey?.setRect(value)
            }.store(in: &cancellables)

            providers.append(
                LayoutRegionLink(
                    source: sourceGuide,
                    destination: destinationGuide
                ))
        }

        self.sourceCellLayoutGuides = sourceCellLayoutGuides
        self.destinationCellLayoutGuides = destinationCellLayoutGuides
        cellInterporator = LayoutLinkAnimator(rootAction: rootAction, layoutLinks: providers)

        update(animated: false)

        collectionLayout.actualCellRegionsPublisher
            .dropFirst().debounce(
                for: .seconds(0.2), scheduler: DispatchQueue.main
            ).sink {
                [weak self] _ in
                self?.update(animated: true)
            }.store(in: &cancellables)

        self.cancellables = cancellables
    }

    private func update(animated: Bool) {
        let cellCount = collectionLayout.actualCellCount
        for (index, softKey) in softKeys.enumerated() {
            if index < cellCount {
                sourceCellLayoutGuides[index].region = collectionLayout.actualCellRegions[index]
            }
            softKey.setEnabled(index < cellCount, animated: animated)
        }
    }
}

@MainActor
final class SoftKey {
    private let button: Button
    private let strings: Strings
    private let rootAction: ParallelAction
    private let actionGroup: ActionGroup = .init()

    private var cancellable: AnyCancellable?

    init(
        key: String, width: Float, fontAtlas: FontAtlas, eventInput: EventInput,
        rootAction: ParallelAction, detector: Detector, renderer: Renderer,
        handler: @MainActor @escaping () -> Void
    ) {
        button = .init(
            region: .init(origin: .zero, size: .init(repeating: width)), eventInput: eventInput,
            detector: detector, renderer: renderer, stateCount: 1)
        strings = .init(fontAtlas: fontAtlas, maxWordCount: 1)
        self.rootAction = rootAction

        button.rectPlane.content.meshes.first?.isMeshColorUsed = true
        button.rectPlane.data.setRectColor(
            .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), rectIndex: 0)
        button.rectPlane.data.setRectColor(
            .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), rectIndex: 1)

        strings.text = key
        strings.alignment = .mid

        button.rectPlane.node.appendSubNode(strings.rectPlane.node)

        let stringsOffsetY = roundf((width + Float(fontAtlas.ascent + fontAtlas.descent)) * 0.5)
        strings.preferredFrame = .init(
            origin: .init(x: 0.0, y: stringsOffsetY), size: .init(width: width, height: 0.0))

        cancellable = button.publisher.sink { context in
            guard context.phase == .ended else { return }
            handler()
        }
    }

    var node: Node { button.rectPlane.node }

    func setEnabled(_ enabled: Bool, animated: Bool = false) {
        let buttonNode = button.rectPlane.node
        let buttonContent = buttonNode.content!
        let stringsNode = strings.rectPlane.node
        let stringContent = stringsNode.content!

        buttonNode.colliders.first?.isEnabled = enabled

        let alpha: Alpha = enabled ? .init(value: 1.0) : .init(value: 0.0)

        rootAction.remove(for: actionGroup)

        if animated {
            rootAction.insert(
                Action.Fading(
                    group: actionGroup, target: buttonContent,
                    beginAlpha: buttonContent.color.alpha,
                    endAlpha: alpha
                ))
            rootAction.insert(
                Action.Fading(
                    group: actionGroup, target: stringContent,
                    beginAlpha: stringContent.color.alpha,
                    endAlpha: alpha
                ))
        } else {
            buttonContent.color.alpha = alpha
            stringContent.color.alpha = alpha
        }

        buttonContent.color.alpha = alpha
        stringContent.color.alpha = alpha
    }

    func setRect(_ region: Region) {
        button.rectPlane.node.geometry.position = region.origin
        button.layoutGuide.region = .init(origin: .zero, size: region.size)
    }
}
