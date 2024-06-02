import Foundation

public typealias Point = PointCpp

extension Point: @retroactive Equatable {}

extension Point {
    public var x: Float {
        get { simd2[0] }
        set { simd2[0] = newValue }
    }

    public var y: Float {
        get { simd2[1] }
        set { simd2[1] = newValue }
    }

    public init() {
        self.init(simd2: .init(0, 0))
    }

    public init(x: Float, y: Float) {
        self.init(simd2: .init(x, y))
    }

    public init(repeating value: Float) {
        self.init(simd2: .init(value, value))
    }

    public init(_ point: UIntPoint) {
        self.init(simd2: point.simd2)
    }

    public init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }

    public var hasValue: Bool { x != 0.0 || y != 0.0 }

    public static let zero: Self = .init()

    public func distance(from rhs: Point) -> Float {
        let x = x - rhs.x
        let y = y - rhs.y
        return sqrtf(x * x + y * y)
    }
}

public func + (lhs: Point, rhs: Point) -> Point {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func - (lhs: Point, rhs: Point) -> Point {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func += (lhs: inout Point, rhs: Point) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}

public func -= (lhs: inout Point, rhs: Point) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

extension Point: @retroactive CustomStringConvertible {
    public var description: String {
        "{x:\(x),y:\(y)}"
    }
}
