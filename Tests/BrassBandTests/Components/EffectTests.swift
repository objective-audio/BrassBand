import Testing

@testable import BrassBand

private struct CommandBufferStub: CommandBuffer {}

private struct SystemStub: RenderSystem {}

private struct EncoderStub: Effect.Encodable {
    func encode(
        sourceTexture: Texture, destinationTexture: Texture, system: any RenderSystem,
        commandBuffer: any CommandBuffer
    ) throws {
    }
}

@MainActor
struct EffectTests {
    @Test func encodeErrorWithSystemNotFound() throws {
        let effect = Effect()
        let commandBuffer = CommandBufferStub()

        #expect(throws: Effect.Error.systemNotFound) {
            try effect.encode(commandBuffer)
        }
    }

    @Test func encodeErrorWithTexturesNotFound() throws {
        let effect = Effect()
        let commandBuffer = CommandBufferStub()
        let system = SystemStub()

        try effect.prepareForRendering(system)

        #expect(throws: Effect.Error.texturesNotFound) {
            try effect.encode(commandBuffer)
        }
    }

    @Test func updates() throws {
        let encoder = EncoderStub()
        let effect = Effect(encodable: encoder)
        let commandBuffer = CommandBufferStub()
        let system = SystemStub()
        let scaleFactorProvider = ScaleFactorProviderStub()

        let sourceTexture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)
        let destinationTexture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)
        effect.set(sourceTexture: sourceTexture, destinationTexture: destinationTexture)

        var treeUpdates = TreeUpdates()

        #expect(treeUpdates.effectUpdates == [])
        #expect(effect.needsRender)

        effect.fetchUpdates(&treeUpdates)

        #expect(treeUpdates.effectUpdates == .all)

        try effect.prepareForRendering(system)
        try effect.encode(commandBuffer)

        #expect(effect.needsRender)

        effect.clearUpdates()

        #expect(!effect.needsRender)

        treeUpdates.effectUpdates = []
        effect.fetchUpdates(&treeUpdates)

        #expect(treeUpdates.effectUpdates == [])
    }
}
