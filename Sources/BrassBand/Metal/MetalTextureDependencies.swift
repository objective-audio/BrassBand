import Foundation

extension MetalTexture {
    @MainActor
    protocol MetalSystem: AnyObject {
        func makeMTLTexture(descriptor: MTLTextureDescriptor) throws -> any MTLTexture
        func makeMTLSamplerState(descriptor: MTLSamplerDescriptor) throws -> any MTLSamplerState
        func makeMTLArgumentEncoder() -> any MTLArgumentEncoder
        func makeMetalBuffer(length: Int) throws -> MetalBuffer
    }
}

extension MetalSystem: MetalTexture.MetalSystem {}
