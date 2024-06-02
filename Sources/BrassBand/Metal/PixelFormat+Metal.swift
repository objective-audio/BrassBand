import Foundation

extension MTLPixelFormat {
    init(_ pixelFormat: PixelFormat) {
        switch pixelFormat {
        case .rgba8Unorm:
            self = .rgba8Unorm
        case .bgra8Unorm:
            self = .bgra8Unorm
        }
    }
}
