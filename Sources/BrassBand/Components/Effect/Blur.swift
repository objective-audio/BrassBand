import Foundation
import MetalPerformanceShaders

@MainActor
public final class Blur {
    enum Error: Swift.Error {
        case makeKernelFailed
        case texturesNotFound
        case invalidCommandBuffer
    }

    public var sigma: Double {
        get { encoder.sigma }
        set { encoder.sigma = newValue }
    }

    public let effect: Effect

    private let encoder: EffectEncoder

    public init() {
        encoder = .init()
        effect = .init(encodable: encoder)
    }
}

extension Blur {
    final class EffectEncoder: Effect.Encodable {
        var sigma: Double = 0.0

        private var prevSigma: Double?
        private var prevScaleFactor: Double?
        private var kernel: (any MetalKernel)?

        func encode(
            sourceTexture: Texture, destinationTexture: Texture,
            system: any RenderSystem, commandBuffer: any CommandBuffer
        ) throws {
            let scaleFactor = sourceTexture.scaleFactor

            if kernel == nil || prevScaleFactor != scaleFactor || prevSigma != sigma {
                prevSigma = sigma
                prevScaleFactor = scaleFactor

                if let metalSystem = system as? any MetalSystem {
                    kernel = metalSystem.makeMetalBlurKernel(sigma: sigma * scaleFactor)
                } else {
                    kernel = nil
                }
            }

            guard let kernel else {
                throw Error.makeKernelFailed
            }

            try kernel.encode(
                commandBuffer: commandBuffer, sourceTexture: sourceTexture,
                destinationTexture: destinationTexture)
        }
    }
}

extension Blur {
    @MainActor
    protocol MetalKernel {
        func encode(
            commandBuffer: any CommandBuffer, sourceTexture: Texture, destinationTexture: Texture)
            throws
    }

    @MainActor
    protocol MetalSystem: RenderSystem {
        func makeMetalBlurKernel(sigma: Double) -> any MetalKernel
    }
}

extension MetalSystem: Blur.MetalSystem {
    func makeMetalBlurKernel(sigma: Double) -> any Blur.MetalKernel {
        let rawKernel: any MetalRawKernel

        if sigma > 0 {
            rawKernel = MPSImageGaussianBlur(device: device, sigma: Float(sigma))
        } else {
            rawKernel = Effect.Through.MetalRawKernel()
        }

        return MetalKernel(raw: rawKernel)
    }
}

extension MPSImageGaussianBlur: MetalRawKernel {}
extension MetalKernel: Blur.MetalKernel {}
