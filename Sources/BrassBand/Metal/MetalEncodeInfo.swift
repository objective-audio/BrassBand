import Foundation

@MainActor
final class MetalEncodeInfo {
    let renderPassDescriptor: MTLRenderPassDescriptor
    let pipelineStateWithTexture: any MTLRenderPipelineState
    let pipelineStateWithoutTexture: any MTLRenderPipelineState

    private(set) var meshes: [Mesh] = []
    private(set) var effects: [Effect] = []
    private(set) var textures: [ObjectIdentifier: Texture] = [:]

    init(
        renderPassDescriptor: MTLRenderPassDescriptor,
        pipelineStateWithTexture: any MTLRenderPipelineState,
        pipelineStateWithoutTexture: any MTLRenderPipelineState
    ) {
        self.renderPassDescriptor = renderPassDescriptor
        self.pipelineStateWithTexture = pipelineStateWithTexture
        self.pipelineStateWithoutTexture = pipelineStateWithoutTexture
    }

    func appendMesh(_ mesh: Mesh) {
        if let texture = mesh.texture {
            let textureId = ObjectIdentifier(texture)
            if textures[textureId] == nil {
                textures[textureId] = texture
            }
        }
        meshes.append(mesh)
    }

    func appendEffect(_ effect: Effect) {
        self.effects.append(effect)
    }
}
