import Foundation
import simd

@MainActor
public final class Collider {
    public enum Kind: Sendable {
        case anywhere, circle, rect
    }

    public var shape: (any Shape)?
    public var isEnabled: Bool = true
    public var kind: Kind? { shape?.kind }

    var matrix: simd_float4x4?

    public init(shape: (any Shape)?) {
        self.shape = shape
    }

    convenience public init() {
        self.init(shape: nil)
    }

    public func hitTest(_ point: Point) -> Bool {
        guard isEnabled, let shape, let matrix else { return false }

        let position = matrix.inverse * point.simd2.simd4

        return shape.hitTest(.init(x: position.x, y: position.y))
    }

    public func hitTest(_ region: Region) -> Bool {
        guard isEnabled, let shape, let matrix else { return false }

        let invertedMatrix = matrix.inverse
        let regionPositions = region.positions
        let minPosition = invertedMatrix * regionPositions.leftBottom.simd4
        let maxPosition = invertedMatrix * regionPositions.rightTop.simd4

        let testRegion = Region(
            origin: .init(x: minPosition.x, y: minPosition.y),
            size: .init(width: maxPosition.x - minPosition.x, height: maxPosition.y - minPosition.y)
        )
        return shape.hitTest(testRegion)
    }
}
