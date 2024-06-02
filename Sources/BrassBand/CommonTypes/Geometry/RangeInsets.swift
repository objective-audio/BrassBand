import Foundation

public struct RangeInsets: Equatable, Sendable {
    public var min: Float
    public var max: Float

    public init(min: Float, max: Float) {
        self.min = min
        self.max = max
    }
}

extension RangeInsets {
    public static let zero: Self = .init(min: 0.0, max: 0.0)
}
