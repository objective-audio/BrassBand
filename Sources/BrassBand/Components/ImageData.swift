import Foundation

struct ImageSize: Sendable {
    let point: UIntSize
    let actual: UIntSize
    let scaleFactor: Double

    init(pointSize: UIntSize, scaleFactor: Double = 1.0) {
        self.point = pointSize
        self.actual = UIntSize(
            width: UInt32(Double(pointSize.width) * scaleFactor),
            height: UInt32(Double(pointSize.height) * scaleFactor))
        self.scaleFactor = scaleFactor
    }
}

struct ImageData: Sendable {
    typealias DrawHandler = @Sendable (CGContext) -> Void

    nonisolated(unsafe) private let bitmapContext: CGContext

    let size: ImageSize

    var data: UnsafeMutableRawPointer { bitmapContext.data! }

    fileprivate init(size: ImageSize, bitmapContext: CGContext) {
        self.size = size
        self.bitmapContext = bitmapContext
    }

    static func make(size: ImageSize, drawHandler: @escaping DrawHandler) -> ImageData? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard
            let bitmapContext = CGContext(
                data: nil, width: Int(size.actual.width), height: Int(size.actual.height),
                bitsPerComponent: 8, bytesPerRow: Int(size.actual.width * 4), space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            return nil
        }

        bitmapContext.saveGState()

        bitmapContext.translateBy(x: 0, y: .init(size.actual.height))
        bitmapContext.scaleBy(
            x: CGFloat(size.actual.width) / CGFloat(size.point.width),
            y: -CGFloat(size.actual.height) / CGFloat(size.point.height))
        drawHandler(bitmapContext)

        bitmapContext.restoreGState()

        return .init(size: size, bitmapContext: bitmapContext)
    }
}
