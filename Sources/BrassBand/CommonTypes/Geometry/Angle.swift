import Foundation

public struct Angle: Sendable {
    public var degrees: Float
    public var radians: Float { degrees * (Float.pi / 180.0) }

    public static let zero: Self = .init(degrees: 0.0)

    public init(degrees: Float) {
        self.degrees = degrees
    }

    public init(radians: Float) {
        self.degrees = radians * (180.0 / Float.pi)
    }

    public func shortest(from: Angle) -> Angle {
        var value = degrees - from.degrees

        if value == 0.0 {
            return .zero
        }

        value /= 360.0
        value -= truncf(value)

        if value > 0.5 {
            value -= 1.0
        } else if value < -0.5 {
            value += 1.0
        }

        return .init(degrees: value * 360.0 + from.degrees)
    }

    public func shortest(to: Angle) -> Angle {
        to.shortest(from: self)
    }
}

extension Angle: Equatable {}

public func + (lhs: Angle, rhs: Angle) -> Angle {
    .init(degrees: lhs.degrees + rhs.degrees)
}

public func - (lhs: Angle, rhs: Angle) -> Angle {
    .init(degrees: lhs.degrees - rhs.degrees)
}

public func * (lhs: Angle, rhs: Float) -> Angle {
    .init(degrees: lhs.degrees * rhs)
}

public func / (lhs: Angle, rhs: Float) -> Angle {
    .init(degrees: lhs.degrees / rhs)
}

public prefix func - (angle: Angle) -> Angle {
    .init(degrees: -angle.degrees)
}

public func += (lhs: inout Angle, rhs: Angle) {
    lhs.degrees += rhs.degrees
}

public func -= (lhs: inout Angle, rhs: Angle) {
    lhs.degrees -= rhs.degrees
}

public func *= (lhs: inout Angle, rhs: Float) {
    lhs.degrees *= rhs
}

public func /= (lhs: inout Angle, rhs: Float) {
    lhs.degrees /= rhs
}
