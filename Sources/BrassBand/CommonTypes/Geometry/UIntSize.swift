import Foundation

public struct UIntSize: Equatable, Sendable {
    public var width: UInt32 = 1
    public var height: UInt32 = 1

    public init(width: UInt32, height: UInt32) {
        self.width = width
        self.height = height
    }

    public init(repeating value: UInt32) {
        width = value
        height = value
    }
}

extension UIntSize {
    public static let zero: Self = .init(width: 0, height: 0)
    public static let one: Self = .init(width: 1, height: 1)
}
