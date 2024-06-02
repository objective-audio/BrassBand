import Foundation

public struct RectShape: Sendable {
    public var rect: Region = .init(center: .zero, size: .one)

    public init() {}
    public init(rect: Region) { self.rect = rect }
}

extension RectShape: Shape {
    public var kind: Collider.Kind { .rect }

    public func hitTest(_ point: Point) -> Bool {
        rect.contains(point)
    }

    public func hitTest(_ region: Region) -> Bool {
        rect.intersected(region) != nil
    }
}
