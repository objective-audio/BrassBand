import Foundation

@MainActor
final class MetalTexture {
    enum Error: Swift.Error {
        case invalidActualSize(_ size: UIntSize)
    }

    let size: UIntSize
    let usage: MTLTextureUsage
    let pixelFormat: MTLPixelFormat

    let samplerState: any MTLSamplerState
    let texture: any MTLTexture
    let textureType: MTLTextureType
    let argumentBuffer: MetalBuffer

    private let argumentEncoder: any MTLArgumentEncoder

    init(
        actualSize: UIntSize, usage: TextureUsage, pixelFormat: PixelFormat,
        system: any MetalTexture.MetalSystem
    ) throws {
        guard actualSize.width > 0 && actualSize.height > 0 else {
            throw Error.invalidActualSize(actualSize)
        }

        size = actualSize
        let mtlUsage = MTLTextureUsage(usage)
        self.usage = mtlUsage
        let mtlPixelFormat = MTLPixelFormat(pixelFormat)
        self.pixelFormat = mtlPixelFormat

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: mtlPixelFormat, width: Int(size.width), height: Int(size.height),
            mipmapped: false)

        textureType = textureDescriptor.textureType
        textureDescriptor.usage = mtlUsage

        texture = try system.makeMTLTexture(descriptor: textureDescriptor)

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .notMipmapped
        samplerDescriptor.maxAnisotropy = 1
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        samplerDescriptor.rAddressMode = .clampToEdge
        samplerDescriptor.normalizedCoordinates = false
        samplerDescriptor.lodMinClamp = 0
        samplerDescriptor.lodMaxClamp = .infinity
        samplerDescriptor.supportArgumentBuffers = true

        samplerState = try system.makeMTLSamplerState(descriptor: samplerDescriptor)

        let encoder = system.makeMTLArgumentEncoder()
        let buffer = try system.makeMetalBuffer(length: encoder.encodedLength)

        argumentEncoder = encoder
        argumentBuffer = buffer

        encoder.setArgumentBuffer(buffer.mtl, offset: 0)
        encoder.setTexture(texture, index: 0)
        encoder.setSamplerState(samplerState, index: 1)
    }

    func replaceData(region: UIntRegion, data: UnsafeRawPointer) {
        texture.replace(
            region: .init(region), mipmapLevel: 0, withBytes: data,
            bytesPerRow: Int(region.size.width * 4))
    }

    func useResource(encoder: any MTLRenderCommandEncoder) {
        encoder.useResource(texture, usage: .read, stages: .vertex)
    }

    func setToColorDescription(_ colorDescription: MTLRenderPassColorAttachmentDescriptor) {
        colorDescription.texture = texture
    }
}
