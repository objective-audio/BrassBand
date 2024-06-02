import Foundation

extension Size {
    public var cgSize: CGSize {
        .init(width: CGFloat(width), height: CGFloat(height))
    }
}
