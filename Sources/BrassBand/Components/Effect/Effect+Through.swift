import Foundation

extension Effect {
    final class Through: Encodable {
        enum Error: Swift.Error {
            case makeKernelFailed
            case makeEncoderFailed
        }

        private var kernel: (any MetalKernel)?

        func encode(
            sourceTexture: Texture, destinationTexture: Texture,
            system: any RenderSystem, commandBuffer: any CommandBuffer
        ) throws {
            if kernel == nil, let metalSystem = system as? any MetalSystem {
                kernel = metalSystem.makeMetalThroughKernel()
            }

            guard let kernel else {
                throw Error.makeKernelFailed
            }

            try kernel.encode(
                commandBuffer: commandBuffer, sourceTexture: sourceTexture,
                destinationTexture: destinationTexture)
        }
    }

    static let throughEncoder: Through = .init()
}

extension Effect.Through {
    @MainActor
    protocol MetalKernel {
        func encode(
            commandBuffer: any CommandBuffer, sourceTexture: Texture, destinationTexture: Texture)
            throws
    }

    @MainActor
    protocol MetalSystem: RenderSystem {
        func makeMetalThroughKernel() -> any MetalKernel
    }

    struct MetalRawKernel: BrassBand.MetalRawKernel {
        func encode(
            commandBuffer: any MTLCommandBuffer, sourceTexture: any MTLTexture,
            destinationTexture: any MTLTexture
        ) throws {
            guard let encoder = commandBuffer.makeBlitCommandEncoder() else {
                throw Error.makeEncoderFailed
            }

            let width = min(sourceTexture.width, destinationTexture.width)
            let height = min(sourceTexture.height, destinationTexture.height)
            let zeroOrigin = MTLOrigin(x: 0, y: 0, z: 0)

            encoder.copy(
                from: sourceTexture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: zeroOrigin,
                sourceSize: .init(width: width, height: height, depth: sourceTexture.depth),
                to: destinationTexture, destinationSlice: 0, destinationLevel: 0,
                destinationOrigin: zeroOrigin)

            encoder.endEncoding()
        }
    }
}

extension MetalSystem: Effect.Through.MetalSystem {
    func makeMetalThroughKernel() -> any Effect.Through.MetalKernel {
        MetalKernel(raw: Effect.Through.MetalRawKernel())
    }
}

extension MetalKernel: Effect.Through.MetalKernel {}
