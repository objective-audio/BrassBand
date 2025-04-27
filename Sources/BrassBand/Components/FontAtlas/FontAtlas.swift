import Foundation

@MainActor
public final class FontAtlas {
    public let fontName: String
    public let fontSize: Double
    public let ascent: Double
    public let descent: Double
    public let leading: Double
    public let texture: Texture

    private let rectsDidUpdateSubject: PassthroughSubject<Void, Never> = .init()
    public var rectsDidUpdate: AnyPublisher<Void, Never> {
        rectsDidUpdateSubject.eraseToAnyPublisher()
    }

    public var words: String {
        wordInfos.keys.sorted().map(String.init).joined()
    }

    private struct WordInfo: Sendable {
        var rect: Vertex2dRect
        let advance: Size
        weak var textureElement: TextureElement?
    }
    private var wordInfos: [Character: WordInfo]
    private let font: CTFont
    private var cancellables: Set<AnyCancellable> = []

    public init(fontName: String, fontSize: Double, words: String, texture: Texture) {
        self.fontName = fontName
        self.fontSize = fontSize

        let font = CTFont(fontName as CFString, size: CGFloat(fontSize))
        self.font = font
        ascent = CTFontGetAscent(font)
        descent = CTFontGetDescent(font)
        leading = CTFontGetLeading(font)

        self.texture = texture
        self.wordInfos = Self.makeWordInfos(
            words: words, font: font, fontName: fontName, fontSize: fontSize, texture: texture)

        updateTexCoords()

        texture.metalTextureDidChange.sink { [weak self] in
            self?.updateTexCoords()
            self?.rectsDidUpdateSubject.send()
        }.store(in: &cancellables)
    }

    private static func makeWordInfos(
        words: String, font: CTFont, fontName: String, fontSize: CGFloat, texture: Texture
    ) -> [Character: WordInfo] {
        var wordInfos: [Character: WordInfo] = [:]

        let wordCount = words.count
        let ascent = CTFontGetAscent(font)
        let descent = CTFontGetDescent(font)

        var glyphs: [CGGlyph] = .init(repeating: .zero, count: wordCount)
        var characters: [UniChar] = .init(repeating: 0, count: wordCount)
        var advances: [CGSize] = .init(repeating: .zero, count: wordCount)

        CFStringGetCharacters(words as CFString, .init(location: 0, length: wordCount), &characters)
        CTFontGetGlyphsForCharacters(font, characters, &glyphs, wordCount)
        CTFontGetAdvancesForGlyphs(font, .default, &glyphs, &advances, wordCount)

        let stringHeight = descent + ascent
        let scaleFactor = texture.scaleFactor

        for (index, word) in words.enumerated() {
            guard wordInfos[word] == nil else {
                continue
            }

            let imageSize = UIntSize(
                width: UInt32(ceil(advances[index].width)),
                height: UInt32(ceil(stringHeight)))
            let imageRegion = Region(
                origin: .init(x: 0.0, y: round(-Float(descent), scale: scaleFactor)),
                size: .init(width: Float(imageSize.width), height: Float(imageSize.height)))

            let textureElement = texture.addElement(size: imageSize) {
                [glyph = glyphs[index]] context in
                context.saveGState()
                defer { context.restoreGState() }

                context.translateBy(x: 0.0, y: CGFloat(imageSize.height))
                context.scaleBy(x: 1.0, y: -1.0)
                context.translateBy(x: 0.0, y: descent)

                context.setFillColor(.init(gray: 1.0, alpha: 1.0))

                let font = CTFont(fontName as CFString, size: CGFloat(fontSize))

                guard let path = CTFontCreatePathForGlyph(font, glyph, nil) else {
                    return
                }

                context.addPath(path)
                context.fillPath()
            }

            let advance = advances[index]

            var rect = Vertex2dRect()
            rect.setPositions(imageRegion.positions)

            wordInfos[word] = .init(
                rect: rect,
                advance: .init(width: Float(advance.width), height: Float(advance.height)),
                textureElement: textureElement)
        }

        return wordInfos
    }

    public func rect(for word: Character) -> Vertex2dRect {
        if let value = wordInfos[word] {
            return value.rect
        } else {
            return .empty
        }
    }

    public func advance(for word: Character) -> Size {
        guard word != "\n" && word != "\r" else {
            return .zero
        }

        guard let value = wordInfos[word] else {
            return .zero
        }

        return value.advance
    }

    private func updateTexCoords() {
        let wordInfos = self.wordInfos
        for (key, value) in wordInfos {
            var rect = value.rect
            if let textureElement = value.textureElement {
                rect.setTexCoords(textureElement.texCoords.positions)
            } else {
                rect.setTexCoords(.zero)
            }
            self.wordInfos[key]?.rect = rect
        }
    }
}
