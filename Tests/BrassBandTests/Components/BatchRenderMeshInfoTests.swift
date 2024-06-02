import Testing

@testable import BrassBand

@MainActor
struct BatchRenderMeshInfoTests {
    @Test(
        "異なるPrimitiveTypeでの初期化をテスト",
        arguments: [
            (PrimitiveType.point),
            (PrimitiveType.line),
            (PrimitiveType.lineStrip),
            (PrimitiveType.triangle),
            (PrimitiveType.triangleStrip),
        ]
    )
    func initialize(primitiveType: PrimitiveType) async throws {
        let info = BatchRenderMeshInfo(primitiveType: primitiveType, texture: nil)

        #expect(info.renderMesh.primitiveType == primitiveType)
        #expect(info.renderMesh.texture == nil)
        #expect(info.renderMesh.isMeshColorUsed)
    }

    @Test(
        "テクスチャの有無による初期化をテスト",
        arguments: [
            false,
            true,
        ]
    )
    func initialize(isTextureMaking: Bool) async throws {
        let texture: Texture? =
            isTextureMaking
            ? Texture(pointSize: .one, scaleFactorProvider: ScaleFactorProviderStub()) : nil
        let info = BatchRenderMeshInfo(primitiveType: .triangle, texture: texture)

        #expect(info.renderMesh.texture === texture)
        #expect(info.renderMesh.isMeshColorUsed)
    }
}
