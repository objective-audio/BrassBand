import Foundation

extension SIMD2<Float> {
    public var simd4: SIMD4<Float> { .init(self[0], self[1], 0.0, 1.0) }

    public mutating func apply(matrix: float4x4) {
        self = applied(matrix: matrix)
    }

    public func applied(matrix: float4x4) -> Self {
        .init((matrix * self.simd4).simd2)
    }
}

extension SIMD4<Float> {
    public var simd2: SIMD2<Float> { lowHalf }
}
