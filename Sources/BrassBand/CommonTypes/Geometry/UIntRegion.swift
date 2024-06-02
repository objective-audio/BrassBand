import Foundation

public struct UIntRegion: Equatable, Sendable {
    public var origin: UIntPoint
    public var size: UIntSize

    public init(origin: UIntPoint, size: UIntSize) {
        self.origin = origin
        self.size = size
    }
}

extension UIntRegion {
    public var left: UInt32 { min(origin.x, origin.x + size.width) }
    public var right: UInt32 { max(origin.x, origin.x + size.width) }
    public var bottom: UInt32 { min(origin.y, origin.y + size.height) }
    public var top: UInt32 { max(origin.y, origin.y + size.height) }

    public var positions: RegionPositions { .init(self) }

    public static let zero: Self = .init(origin: .zero, size: .zero)
}
