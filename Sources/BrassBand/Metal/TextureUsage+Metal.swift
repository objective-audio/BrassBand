import Foundation

extension MTLTextureUsage {
    init(_ usage: TextureUsage) {
        var result: MTLTextureUsage = []

        if usage.contains(.shaderRead) {
            result.insert(.shaderRead)
        }

        if usage.contains(.shaderWrite) {
            result.insert(.shaderWrite)
        }

        if usage.contains(.renderTarget) {
            result.insert(.renderTarget)
        }

        self = result
    }
}
