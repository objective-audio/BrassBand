import Foundation

extension Texture {
    @MainActor
    protocol MetalSystem: AnyObject, RenderSystem {
        func makeMetalTextureForTexture(
            actualSize: UIntSize, usage: TextureUsage, pixelFormat: PixelFormat
        ) throws
            -> any MetalTexture
    }

    @MainActor
    protocol MetalTexture {
        var texture: any MTLTexture { get }
        var argumentBuffer: MetalBuffer { get }
        func replaceData(region: UIntRegion, data: UnsafeRawPointer)
        func useResource(encoder: any MTLRenderCommandEncoder)
        func setToColorDescription(_ description: MTLRenderPassColorAttachmentDescriptor)
    }

    @MainActor
    public protocol ScaleFactorProviding {
        var scaleFactor: Double { get }
        var scaleFactorPublisher: AnyPublisher<Double, Never> { get }
    }
}

extension MetalSystem: Texture.MetalSystem {
    func makeMetalTextureForTexture(
        actualSize: UIntSize, usage: TextureUsage, pixelFormat: PixelFormat
    ) throws -> any Texture.MetalTexture {
        try makeMetalTexture(actualSize: actualSize, usage: usage, pixelFormat: pixelFormat)
    }
}

extension MetalTexture: Texture.MetalTexture {}
extension ViewLook: Texture.ScaleFactorProviding {}
