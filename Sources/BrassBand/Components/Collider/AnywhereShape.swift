import Foundation

public struct AnywhereShape {
    public init() {}
}

extension AnywhereShape: Shape {
    public var kind: Collider.Kind { .anywhere }

    public func hitTest(_ point: Point) -> Bool {
        true
    }

    public func hitTest(_ region: Region) -> Bool {
        true
    }
}
