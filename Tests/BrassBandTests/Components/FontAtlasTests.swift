import Testing

@testable import BrassBand

@MainActor
struct FontAtlasTests {
    private let provider = ScaleFactorProviderStub()
    private let texture: Texture

    init() {
        texture = Texture(
            pointSize: .init(width: 256, height: 256), drawPadding: 0, usage: .shaderRead,
            pixelFormat: .rgba8Unorm, scaleFactorProvider: provider)
    }

    @Test func initial() async throws {
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "aabcde12345", texture: texture)

        #expect(fontAtlas.fontName == "HelveticaNeue")
        #expect(fontAtlas.fontSize == 14.0)
        #expect(fontAtlas.words == "12345abcde")
        #expect(fontAtlas.texture === texture)

        let font = CTFontCreateWithName("HelveticaNeue" as CFString, 14.0, nil)
        #expect(
            fontAtlas.ascent.isApproximatelyEqual(
                to: CTFontGetAscent(font), absoluteTolerance: 0.001))
        #expect(
            fontAtlas.descent.isApproximatelyEqual(
                to: CTFontGetDescent(font), absoluteTolerance: 0.001))
        #expect(
            fontAtlas.leading.isApproximatelyEqual(
                to: CTFontGetLeading(font), absoluteTolerance: 0.001))
    }

    @Test func rect() {
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "a1", texture: texture)

        #expect(fontAtlas.rect(for: "a") != .empty)
        #expect(fontAtlas.rect(for: "1") != .empty)
        #expect(fontAtlas.rect(for: "b") == .empty)
        #expect(fontAtlas.rect(for: "\n") == .empty)
        #expect(fontAtlas.rect(for: "\r") == .empty)
    }

    @Test func advance() throws {
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "a1", texture: texture)

        #expect(fontAtlas.advance(for: "a") != .zero)
        #expect(fontAtlas.advance(for: "1") != .zero)
        #expect(fontAtlas.advance(for: "b") == .zero)
        #expect(fontAtlas.advance(for: "\n") == .zero)
        #expect(fontAtlas.advance(for: "\r") == .zero)
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func prepareForRendering() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "a1", texture: texture)

        try fontAtlas.texture.prepareForRendering(system: system)
    }
}
