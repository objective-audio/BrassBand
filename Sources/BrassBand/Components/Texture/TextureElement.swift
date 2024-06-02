import Foundation

@MainActor
public final class TextureElement {
    let size: UIntSize
    let drawHandler: ImageData.DrawHandler
    @CurrentValue public internal(set) var texCoords: UIntRegion = .zero

    init(size: UIntSize, drawHandler: @escaping ImageData.DrawHandler) {
        self.size = size
        self.drawHandler = drawHandler
    }
}
