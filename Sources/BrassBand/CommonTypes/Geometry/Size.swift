import Foundation

public struct Size: Equatable, Sendable {
    public var width: Float = 0.0
    public var height: Float = 0.0

    public init() {
        width = 0.0
        height = 0.0
    }

    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }

    public init(repeating value: Float) {
        self.width = value
        self.height = value
    }

    public init(_ size: UIntSize) {
        width = Float(size.width)
        height = Float(size.height)
    }

    public init(simd2: SIMD2<Float>) {
        width = simd2[0]
        height = simd2[1]
    }
}

extension Size {
    public var hasValue: Bool { width != 0.0 || height != 0.0 }

    public static let zero: Self = .init(width: 0.0, height: 0.0)
    public static let one: Self = .init(width: 1.0, height: 1.0)
}

public func + (lhs: Size, rhs: Size) -> Size {
    .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func - (lhs: Size, rhs: Size) -> Size {
    .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

public func += (lhs: inout Size, rhs: Size) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}

public func -= (lhs: inout Size, rhs: Size) {
    lhs.width -= rhs.width
    lhs.height -= rhs.height
}

public func * (lhs: Size, rhs: Float) -> Size {
    .init(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func / (lhs: Size, rhs: Float) -> Size {
    .init(width: lhs.width / rhs, height: lhs.height / rhs)
}

public func *= (lhs: inout Size, rhs: Float) {
    lhs.width *= rhs
    lhs.height *= rhs
}

public func /= (lhs: inout Size, rhs: Float) {
    lhs.width /= rhs
    lhs.height /= rhs
}
