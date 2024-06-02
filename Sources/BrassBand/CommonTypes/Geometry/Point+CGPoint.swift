import Foundation

extension Point {
    public var cgPoint: CGPoint {
        .init(x: CGFloat(x), y: CGFloat(y))
    }
}
