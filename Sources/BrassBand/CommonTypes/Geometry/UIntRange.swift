import Foundation

public struct UIntRange: Equatable, Sendable {
    public var location: UInt32
    public var length: UInt32

    public init(location: UInt32, length: UInt32) {
        self.location = location
        self.length = length
    }
}

extension UIntRange {
    public var min: UInt32 { Swift.min(location, location + length) }
    public var max: UInt32 { Swift.max(location, location + length) }

    public static let zero: Self = .init(location: 0, length: 0)
}
