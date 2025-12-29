import Testing

@testable import BrassBand

@MainActor
struct FontAtlasTests {
    private func makeTexture(scaleFactor: Double = 1.0) -> (ScaleFactorProviderStub, Texture) {
        let provider = ScaleFactorProviderStub(scaleFactor: scaleFactor)
        let texture = Texture(
            pointSize: .init(width: 256, height: 256), drawPadding: 0, usage: .shaderRead,
            pixelFormat: .rgba8Unorm, scaleFactorProvider: provider)
        return (provider, texture)
    }

    @Test func initial() async throws {
        let (_, texture) = makeTexture()
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
        let (_, texture) = makeTexture()
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "a1", texture: texture)

        #expect(fontAtlas.rect(for: "a") != .empty)
        #expect(fontAtlas.rect(for: "1") != .empty)
        #expect(fontAtlas.rect(for: "b") == .empty)
        #expect(fontAtlas.rect(for: "\n") == .empty)
        #expect(fontAtlas.rect(for: "\r") == .empty)
    }

    @Test func advance() throws {
        let (_, texture) = makeTexture()
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
        let (_, texture) = makeTexture()
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "a1", texture: texture)

        try fontAtlas.texture.prepareForRendering(system: system)
    }

    @Test func scaleFactorUpdate() {
        let (provider, texture) = makeTexture(scaleFactor: 0.0)
        let fontAtlas = FontAtlas(
            fontName: "HelveticaNeue", fontSize: 14.0, words: "a", texture: texture)

        // rect is empty when scaleFactor is 0
        #expect(fontAtlas.rect(for: "a") == .empty)

        // change scaleFactor to 1.0
        provider.scaleFactor = 1.0

        // rect is no longer empty
        #expect(fontAtlas.rect(for: "a") != .empty)
    }
}
