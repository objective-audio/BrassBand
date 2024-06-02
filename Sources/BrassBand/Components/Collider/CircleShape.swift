import Foundation
import simd

public struct CircleShape {
    public var center: Point = .zero
    public var radius: Float = 0.5

    public init() {}

    public init(center: Point, radius: Float) {
        self.center = center
        self.radius = radius
    }
}

extension CircleShape: Shape {
    public var kind: Collider.Kind { .circle }

    public func hitTest(_ point: Point) -> Bool {
        pow(point.x - center.x, 2.0) + pow(point.y - center.y, 2.0) < pow(radius, 2.0)
    }

    public func hitTest(_ region: Region) -> Bool {
        let hRange = region.horizontalRange
        let vRange = region.verticalRange
        let clamped = clamp(
            center.simd2, min: .init(x: hRange.min, y: vRange.min),
            max: .init(x: hRange.max, y: vRange.max))
        return hitTest(Point(simd2: clamped))
    }
}
