import Foundation
import MetalPerformanceShaders

@MainActor
protocol MetalRawKernel {
    func encode(
        commandBuffer: any MTLCommandBuffer, sourceTexture: any MTLTexture,
        destinationTexture: any MTLTexture) throws
}

@MainActor
struct MetalKernel {
    enum Error: Swift.Error {
        case texturesNotFound
        case invalidCommandBuffer
    }

    let raw: any MetalRawKernel

    func encode(
        commandBuffer: any CommandBuffer, sourceTexture: Texture, destinationTexture: Texture
    ) throws {
        guard let sourceMtlTexture = sourceTexture.metalTexture?.texture,
            let destinationMtlTexture = destinationTexture.metalTexture?.texture
        else {
            throw Error.texturesNotFound
        }

        guard let metalCommandBuffer = (commandBuffer as? MetalCommandBuffer)?.value else {
            throw Error.invalidCommandBuffer
        }

        try raw.encode(
            commandBuffer: metalCommandBuffer, sourceTexture: sourceMtlTexture,
            destinationTexture: destinationMtlTexture)
    }
}
