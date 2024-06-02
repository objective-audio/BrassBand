import Foundation

@testable import BrassBand

final class ScaleFactorProviderStub: Texture.ScaleFactorProviding {
    @CurrentValue var scaleFactor: Double
    var scaleFactorPublisher: AnyPublisher<Double, Never> {
        $scaleFactor.eraseToAnyPublisher()
    }

    init(scaleFactor: Double = 1.0) {
        self.scaleFactor = scaleFactor
    }
}

struct KernelStub {
    let encodeHandler: @Sendable () -> Void

    func encode(
        commandBuffer: any CommandBuffer, sourceTexture: Texture,
        destinationTexture: Texture
    ) throws {
        encodeHandler()
    }
}
