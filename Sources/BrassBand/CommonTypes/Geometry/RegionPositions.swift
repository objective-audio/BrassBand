import Foundation

public struct RegionPositions: Sendable {
    private var v: [SIMD2<Float>]

    public init(_ region: Region) {
        let left = region.left
        let right = region.right
        let bottom = region.bottom
        let top = region.top
        v = [.init(left, bottom), .init(right, bottom), .init(left, top), .init(right, top)]
    }

    public init(_ region: UIntRegion) {
        let left = Float(region.left)
        let right = Float(region.right)
        let bottom = Float(region.bottom)
        let top = Float(region.top)
        v = [.init(left, top), .init(right, top), .init(left, bottom), .init(right, bottom)]
    }

    public subscript(_ index: Int) -> SIMD2<Float> {
        get { v[index] }
        set { v[index] = newValue }
    }

    public var leftBottom: SIMD2<Float> { self[0] }
    public var rightBottom: SIMD2<Float> { self[1] }
    public var leftTop: SIMD2<Float> { self[2] }
    public var rightTop: SIMD2<Float> { self[3] }

    public static let zero: Self = .init(UIntRegion.zero)
}

extension RegionPositions {
    public func applied(matrix: float4x4) -> RegionPositions {
        var positions = self

        for index in 0..<4 {
            positions[index] = (matrix * positions.v[index].simd4).simd2
        }

        return positions
    }
}
