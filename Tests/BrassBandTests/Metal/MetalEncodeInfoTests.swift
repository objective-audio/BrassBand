import Testing

@testable import BrassBand

@MainActor
@Suite(.enabled(if: isMetalSystemAvailable))
struct MetalEncodeInfoTests {
    let renderPassDescriptor: MTLRenderPassDescriptor
    let metalEncodeInfo: MetalEncodeInfo
    let pipelineStateWithTexture: any MTLRenderPipelineState
    let pipelineStateWithoutTexture: any MTLRenderPipelineState

    init() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        renderPassDescriptor = MTLRenderPassDescriptor()
        let defaultLibrary = try #require(ShaderBundle.defaultMetalLibrary(device: device))
        let vertexFunction = defaultLibrary.makeFunction(name: "vertex2d")
        let pipelineStateDescription = MTLRenderPipelineDescriptor()
        pipelineStateDescription.vertexFunction = vertexFunction
        pipelineStateWithTexture = try device.makeRenderPipelineState(
            descriptor: pipelineStateDescription)
        pipelineStateWithoutTexture = try device.makeRenderPipelineState(
            descriptor: pipelineStateDescription)

        metalEncodeInfo = MetalEncodeInfo(
            renderPassDescriptor: renderPassDescriptor,
            pipelineStateWithTexture: pipelineStateWithTexture,
            pipelineStateWithoutTexture: pipelineStateWithoutTexture)
    }

    @Test func initialProperties() {
        #expect(metalEncodeInfo.renderPassDescriptor === renderPassDescriptor)
        #expect(metalEncodeInfo.pipelineStateWithTexture === pipelineStateWithTexture)
        #expect(metalEncodeInfo.pipelineStateWithoutTexture === pipelineStateWithoutTexture)
        #expect(metalEncodeInfo.meshes.isEmpty)
        #expect(metalEncodeInfo.effects.isEmpty)
        #expect(metalEncodeInfo.textures.isEmpty)
    }

    @Test func appendMesh() {
        let scaleFactorProvider = ScaleFactorProviderStub()
        let texture = Texture(
            pointSize: .init(repeating: 1), scaleFactorProvider: scaleFactorProvider)
        let mesh = Mesh(texture: texture)

        metalEncodeInfo.appendMesh(mesh)

        #expect(metalEncodeInfo.meshes.count == 1)
        #expect(metalEncodeInfo.meshes[0] === mesh)
        #expect(metalEncodeInfo.textures.count == 1)
        #expect(
            metalEncodeInfo.textures.contains(where: { (key: ObjectIdentifier, value: Texture) in
                key == ObjectIdentifier(texture) && value === texture
            }))
    }

    @Test func appendEffect() {
        let effect = Effect()

        metalEncodeInfo.appendEffect(effect)

        #expect(metalEncodeInfo.effects.count == 1)
        #expect(metalEncodeInfo.effects[0] === effect)
    }
}
