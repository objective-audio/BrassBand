import DequeModule
import Foundation

@MainActor
final class MetalEncoder {
    private(set) var allEncodeInfos: Deque<MetalEncodeInfo> = .init()
    private(set) var currentEncodeInfos: Deque<MetalEncodeInfo> = .init()

    struct EncodeResult {
        let encodedMeshCount: Int
    }

    func encode(system: MetalSystem, commandBuffer: any CommandBuffer) -> EncodeResult {
        system.prepareUniformsBuffer(uniformsCount: meshCountInAllEncodeInfos)

        var encodedCount: Int = 0

        for encodeInfo in allEncodeInfos {
            let renderPassDescription = encodeInfo.renderPassDescriptor

            guard
                let metalCommandBuffer = (commandBuffer as? MetalCommandBuffer)?.value,
                let encoder = metalCommandBuffer.makeRenderCommandEncoder(
                    descriptor: renderPassDescription)
            else {
                continue
            }

            for mesh in encodeInfo.meshes {
                if mesh.preRender() {
                    system.meshEncode(mesh: mesh, encoder: encoder, encodeInfo: encodeInfo)
                    encodedCount += 1
                }
            }

            for (_, texture) in encodeInfo.textures {
                if let metalTexture = texture.metalTexture {
                    metalTexture.useResource(encoder: encoder)
                } else {
                    assertionFailure()
                }
            }

            encoder.endEncoding()

            for effect in encodeInfo.effects {
                try? effect.encode(commandBuffer)
            }
        }

        return .init(encodedMeshCount: encodedCount)
    }

    private var meshCountInAllEncodeInfos: Int {
        allEncodeInfos.reduce(into: 0) { partialResult, encodeInfo in
            partialResult += encodeInfo.meshes.count
        }
    }
}

extension MetalEncoder: RenderEncodable {
    func appendMesh(_ mesh: Mesh) {
        currentEncodeInfo?.appendMesh(mesh)
    }
}

extension MetalEncoder: RenderStackable {
    func pushEncodeInfo(_ info: MetalEncodeInfo) {
        allEncodeInfos.prepend(info)
        currentEncodeInfos.prepend(info)
    }

    func popEncodeInfo() {
        currentEncodeInfos.removeFirst()
    }

    var currentEncodeInfo: MetalEncodeInfo? {
        currentEncodeInfos.first
    }
}

extension MetalEncoder: RenderEffectable {
    func appendEffect(_ effect: Effect) {
        currentEncodeInfo?.appendEffect(effect)
    }
}
