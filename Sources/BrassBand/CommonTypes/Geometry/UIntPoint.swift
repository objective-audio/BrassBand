import Foundation

public struct UIntPoint: Equatable, Sendable {
    public var x: UInt32 = 0
    public var y: UInt32 = 0

    public init(x: UInt32, y: UInt32) {
        self.x = x
        self.y = y
    }
}

extension UIntPoint {
    public static let zero: Self = .init(x: 0, y: 0)

    public var simd2: SIMD2<Float> { .init(Float(x), Float(y)) }
}
