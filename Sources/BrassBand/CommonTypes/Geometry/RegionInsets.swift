import Foundation

public struct RegionInsets: Equatable, Sendable {
    public var left: Float = 0.0
    public var right: Float = 0.0
    public var bottom: Float = 0.0
    public var top: Float = 0.0

    public init(left: Float, right: Float, bottom: Float, top: Float) {
        self.left = left
        self.right = right
        self.bottom = bottom
        self.top = top
    }
}

extension RegionInsets {
    public static let zero: Self = .init(left: 0.0, right: 0.0, bottom: 0.0, top: 0.0)
}
