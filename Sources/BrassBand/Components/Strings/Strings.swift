import Foundation

@MainActor
public final class Strings {
    let collectionLayout: CollectionLayout
    let fontAtlas: FontAtlas
    let maxWordCount: Int

    private var collectionWords: [Character] = []

    public let rectPlane: RectPlane

    public var text: String {
        didSet { updateCollectionLayout() }
    }

    public var attributes: [StringsAttribute] {
        didSet { updateDataRectColors() }
    }

    public var lineHeight: Float? {
        didSet { updateCollectionLayout() }
    }

    private var cancellables: Set<AnyCancellable> = []

    public init(
        text: String = "", fontAtlas: FontAtlas, maxWordCount: Int = 16,
        attributes: [StringsAttribute] = [], lineHeight: Float? = nil,
        alignment: LayoutAlignment = .min, frame: Region = .zero
    ) {
        self.text = text
        self.fontAtlas = fontAtlas
        self.attributes = attributes
        self.lineHeight = lineHeight
        self.maxWordCount = maxWordCount

        collectionLayout = .init(
            frame: frame, defaultCellSize: .zero, alignment: alignment, rowOrder: .descending)
        rectPlane = .init(rectCount: maxWordCount)

        rectPlane.content.meshes.first?.texture = fontAtlas.texture

        fontAtlas.rectsDidUpdate.sink { [weak self] in
            self?.updateCollectionLayout()
        }.store(in: &cancellables)

        collectionLayout.actualCellRegionsPublisher.dropFirst().sink { [weak self] _ in
            self?.updateDataRects()
        }.store(in: &cancellables)

        updateCollectionLayout()
        updateDataRects()
    }

    public var alignment: LayoutAlignment {
        get { collectionLayout.alignment }
        set { collectionLayout.alignment = newValue }
    }
    public var actualFrame: Region { collectionLayout.actualFrame }
    public var actualCellRegions: [Region] { collectionLayout.actualCellRegions }
    public var preferredFrame: Region {
        get { collectionLayout.preferredFrame }
        set { collectionLayout.preferredFrame = newValue }
    }
    public var actualFrameLayoutSource: some LayoutRegionSource {
        collectionLayout.actualFrameLayoutSource
    }

    private func updateCollectionLayout() {
        guard fontAtlas.texture.metalTexture != nil else {
            collectionWords = []
            collectionLayout.preferredCellCount = 0
            rectPlane.data.rectCount = 0
            return
        }

        let sourceText = text
        let wordCount = min(sourceText.count, maxWordCount)
        var collectionWords: [Character] = []
        collectionWords.reserveCapacity(wordCount)
        let cellHeight = self.cellHeight

        var lines: [CollectionLayout.Line] = []
        var cellSizes: [CollectionLayout.CellSize] = []

        for index in 0..<wordCount {
            let stringIndex = sourceText.index(sourceText.startIndex, offsetBy: index)
            let word = sourceText[stringIndex]
            if word == "\n" || word == "\r" {
                lines.append(.init(cellSizes: cellSizes, newLineMinOffset: cellHeight))
                cellSizes.removeAll()
            } else {
                let advance = fontAtlas.advance(for: word)
                cellSizes.append(.init(column: .fixed(advance.width), row: cellHeight))
                collectionWords.append(word)
            }
        }

        if !cellSizes.isEmpty {
            lines.append(.init(cellSizes: cellSizes, newLineMinOffset: cellHeight))
        }

        self.collectionWords = collectionWords
        collectionLayout.lines = lines
        collectionLayout.preferredCellCount = collectionWords.count
        updateDataRects()
    }

    private func updateDataRects() {
        let cellCount = min(collectionLayout.actualCellCount, collectionWords.count)
        let rectPlaneData = rectPlane.data
        rectPlaneData.rectCount = cellCount

        guard cellCount > 0 else { return }

        let ascent = Float(fontAtlas.ascent)

        for index in 0..<cellCount {
            let word = collectionWords[index]
            let region = collectionLayout.actualCellRegions[index]

            var strRect = fontAtlas.rect(for: word)

            let offset = Point(x: region.left, y: region.top - ascent).simd2
            strRect.vertices.0.position += offset
            strRect.vertices.1.position += offset
            strRect.vertices.2.position += offset
            strRect.vertices.3.position += offset

            rectPlaneData.setRect(strRect, rectIndex: index)
            rectPlaneData.setRectColor(rectColor(at: index), rectIndex: index)
        }
    }

    private func updateDataRectColors() {
        let rectPlaneData = rectPlane.data

        for index in 0..<rectPlaneData.rectCount {
            let color = rectColor(at: index)
            rectPlaneData.setRectColor(color, rectIndex: index)
        }
    }

    private func rectColor(at index: Int) -> Color {
        for attribute in attributes {
            if attribute.range?.contains(index) ?? false {
                return attribute.color
            }
        }
        return .init(rgb: .white, alpha: .one)
    }

    private var cellHeight: Float {
        if let lineHeight {
            return lineHeight
        } else {
            return Float(fontAtlas.ascent + fontAtlas.descent + fontAtlas.leading)
        }
    }
}
