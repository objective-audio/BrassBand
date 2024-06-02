import Foundation

public struct LayoutBorders: Sendable {
    public var top: Float = 0.0
    public var bottom: Float = 0.0
    public var left: Float = 0.0
    public var right: Float = 0.0

    public static let zero: LayoutBorders = .init()

    public init(top: Float = 0.0, bottom: Float = 0.0, left: Float = 0.0, right: Float = 0.0) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}

extension LayoutBorders: Equatable {}
