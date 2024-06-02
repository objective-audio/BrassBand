import Testing

@testable import BrassBand

@MainActor
struct StringsTests {
    @Test func initial() {
        let provider = ScaleFactorProviderStub()

        let texture = Texture(pointSize: .init(repeating: 256), scaleFactorProvider: provider)
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "12345_abcdefstx", texture: texture)

        let frame = Region(origin: .init(x: 10.0, y: 20.0), size: .init(width: 30.0, height: 40.0))

        let attributes: [StringsAttribute] = [
            .init(range: nil, color: .init(rgb: .white, alpha: .one)),
            .init(
                range: .init(index: 1, length: 2), color: .init(rgb: .red, alpha: .init(value: 0.5))
            ),
        ]

        let strings = Strings(
            text: "test_text", fontAtlas: fontAtlas, maxWordCount: 1, attributes: attributes,
            lineHeight: 10.0, alignment: .mid, frame: frame)

        #expect(strings.rectPlane.data.vertexData.rawMeshData.capacity == 4)
        #expect(strings.text == "test_text")
        #expect(strings.attributes.count == 2)
        #expect(strings.attributes == attributes)
        #expect(strings.fontAtlas === fontAtlas)
        #expect(strings.lineHeight == 10.0)
        #expect(strings.alignment == .mid)
    }

    @Test("各プロパティに値をセットして状態を確認する", .enabled(if: isMetalSystemAvailable))
    func setValues() throws {
        let provider = ScaleFactorProviderStub()

        let texture = Texture(pointSize: .init(repeating: 256), scaleFactorProvider: provider)
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "12345_abcdefstx", texture: texture)
        let strings = Strings(fontAtlas: fontAtlas)

        strings.text = "test_text"

        #expect(strings.text == "test_text")
        #expect(strings.rectPlane.data.rectCount == 0)

        #expect(strings.lineHeight == nil)

        strings.lineHeight = 20.0

        #expect(strings.lineHeight == 20.0)

        strings.alignment = .max

        #expect(strings.alignment == .max)

        strings.preferredFrame = .init(origin: .zero, size: .init(width: 1024.0, height: 0.0))

        #expect(strings.rectPlane.data.rectCount == 0)

        // textureのprepareForRenderingを呼び出し、rectCountが変わることを確認
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        try texture.prepareForRendering(system: system)

        #expect(strings.rectPlane.data.rectCount > 0)

        // attributesを変更して確認
        let newAttributes: [StringsAttribute] = [
            .init(range: nil, color: .init(rgb: .blue, alpha: .one)),
            .init(
                range: .init(index: 0, length: 4),
                color: .init(rgb: .green, alpha: .init(value: 0.5))),
        ]
        strings.attributes = newAttributes
        #expect(strings.attributes == newAttributes)

        // actualFrameとactualCellRegionsの確認
        #expect(strings.actualCellRegions.count > 0)

        // 実際のフレームサイズが適切な範囲内にあることを確認
        #expect(strings.actualFrame.size.width > 0)
        #expect(strings.actualFrame.size.height > 0)
        #expect(strings.actualFrame.size.width <= strings.preferredFrame.size.width)

        // セル領域が正しく設定されていることを確認
        for region in strings.actualCellRegions {
            #expect(region.size.width > 0)
            #expect(region.size.height > 0)
        }
    }

    @Test("wordsに改行が含まれている場合の状態の確認", .enabled(if: isMetalSystemAvailable))
    func wordsWithNewline() throws {
        let provider = ScaleFactorProviderStub()
        let texture = Texture(pointSize: .init(repeating: 256), scaleFactorProvider: provider)
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "abc\ndef\n123", texture: texture)

        let strings = Strings(fontAtlas: fontAtlas)
        strings.text = "test\ntext\n123"
        strings.lineHeight = 20.0
        strings.preferredFrame = .init(origin: .zero, size: .init(width: 1024.0, height: 0.0))

        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        try texture.prepareForRendering(system: system)

        // 改行を含むテキストが正しく処理されることを確認
        #expect(strings.rectPlane.data.rectCount > 0)
        #expect(strings.text == "test\ntext\n123")
    }
}
