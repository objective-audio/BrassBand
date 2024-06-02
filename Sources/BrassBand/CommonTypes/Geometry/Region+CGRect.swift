import Foundation

extension Region {
    public var cgRect: CGRect {
        .init(origin: origin.cgPoint, size: size.cgSize)
    }
}
