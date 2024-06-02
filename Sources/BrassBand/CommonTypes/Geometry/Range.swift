import Foundation

public struct Range: Equatable, Sendable {
    public var location: Float = 0.0
    public var length: Float = 0.0

    public init(location: Float, length: Float) {
        self.location = location
        self.length = length
    }

    public init(_ range: UIntRange) {
        self.location = Float(range.location)
        self.length = Float(range.length)
    }
}

extension Range {
    public var min: Float {
        get { Swift.min(location, location + length) }
        set {
            self = .init(location: newValue, length: Swift.max(max - newValue, 0.0))
        }
    }
    public var max: Float {
        get { Swift.max(location, location + length) }
        set {
            let location = Swift.min(min, newValue)
            self = .init(location: location, length: Swift.max(0, newValue - location))
        }
    }

    public var insets: RangeInsets { .init(min: min, max: max) }

    public func combined(_ rhs: Range) -> Range {
        let min = Swift.min(self.min, rhs.min)
        let max = Swift.max(self.max, rhs.max)
        return .init(location: min, length: max - min)
    }

    public func intersected(_ rhs: Range) -> Range? {
        let min = Swift.max(self.min, rhs.min)
        let max = Swift.min(self.max, rhs.max)

        if min <= max {
            return .init(location: min, length: max - min)
        } else {
            return nil
        }
    }

    public static let zero: Self = .init(location: 0, length: 0)
}

public func + (lhs: Range, rhs: RangeInsets) -> Range {
    let tmpMin = lhs.min + rhs.min
    let tmpMax = lhs.max + rhs.max
    let min = Swift.min(tmpMin, tmpMax)
    let max = Swift.max(tmpMin, tmpMax)
    return .init(location: min, length: max - min)
}

public func - (lhs: Range, rhs: RangeInsets) -> Range {
    let tmpMin = lhs.min - rhs.min
    let tmpMax = lhs.max - rhs.max
    let min = Swift.min(tmpMin, tmpMax)
    let max = Swift.max(tmpMin, tmpMax)
    return .init(location: min, length: max - min)
}

public func += (lhs: inout Range, rhs: RangeInsets) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Range, rhs: RangeInsets) {
    lhs = lhs - rhs
}
