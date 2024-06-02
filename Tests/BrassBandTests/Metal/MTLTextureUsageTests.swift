import Testing

@testable import BrassBand

struct MTLTextureUsageTests {
    @Test(
        arguments: [
            (TextureUsage.renderTarget, MTLTextureUsage.renderTarget),
            (TextureUsage.shaderRead, MTLTextureUsage.shaderRead),
            (TextureUsage.shaderWrite, MTLTextureUsage.shaderWrite),
            (TextureUsage.all, MTLTextureUsage([.renderTarget, .shaderRead, .shaderWrite])),
        ]
    )
    func initialize(source: TextureUsage, expected: MTLTextureUsage) async throws {
        #expect(MTLTextureUsage(source) == expected)
    }

}
