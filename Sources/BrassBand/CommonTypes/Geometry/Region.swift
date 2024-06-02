import Foundation

public struct Region: Sendable, Equatable {
    public var origin: Point = .zero
    public var size: Size = .zero

    public init() {
        origin = .zero
        size = .zero
    }

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    public init(center: Point, size: Size) {
        origin = .init(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        self.size = size
    }

    public init(simd4: SIMD4<Float>) {
        origin = .init(simd2: simd4.lowHalf)
        size = .init(simd2: simd4.highHalf)
    }

    public init(_ region: UIntRegion) {
        origin = .init(region.origin)
        size = .init(region.size)
    }
}

extension Region {
    public struct Ranges: Sendable {
        let vertical: Range
        let horizontal: Range
    }

    public init(ranges: Ranges) {
        self = .init(
            origin: .init(x: ranges.horizontal.location, y: ranges.vertical.location),
            size: .init(width: ranges.horizontal.length, height: ranges.vertical.length))
    }
}

extension Region {
    public var horizontalRange: Range {
        get { .init(location: origin.x, length: size.width) }
        set { self = .init(horizontalRange: newValue, verticalRange: verticalRange) }
    }

    public var verticalRange: Range {
        get { .init(location: origin.y, length: size.height) }
        set { self = .init(horizontalRange: horizontalRange, verticalRange: newValue) }
    }

    public var left: Float {
        get { horizontalRange.min }
        set {
            var horizontalRange = self.horizontalRange
            horizontalRange.min = newValue
            self = .init(horizontalRange: horizontalRange, verticalRange: verticalRange)
        }
    }
    public var right: Float {
        get { horizontalRange.max }
        set {
            var horizontalRange = self.horizontalRange
            horizontalRange.max = newValue
            self = .init(horizontalRange: horizontalRange, verticalRange: verticalRange)
        }
    }
    public var bottom: Float {
        get { verticalRange.min }
        set {
            var verticalRange = self.verticalRange
            verticalRange.min = newValue
            self = .init(horizontalRange: self.horizontalRange, verticalRange: verticalRange)
        }
    }
    public var top: Float {
        get { verticalRange.max }
        set {
            var verticalRange = self.verticalRange
            verticalRange.max = newValue
            self = .init(horizontalRange: self.horizontalRange, verticalRange: verticalRange)
        }
    }

    public var hasValue: Bool { origin.hasValue || size.hasValue }

    public var insets: RegionInsets { .init(left: left, right: right, bottom: bottom, top: top) }
    public var center: Point {
        .init(x: origin.x + size.width * 0.5, y: origin.y + size.height * 0.5)
    }

    public func combined(_ rhs: Region) -> Self {
        let hRange = horizontalRange.combined(rhs.horizontalRange)
        let vRange = verticalRange.combined(rhs.verticalRange)
        return .init(horizontalRange: hRange, verticalRange: vRange)
    }

    public func intersected(_ rhs: Region) -> Self? {
        guard let hRange = horizontalRange.intersected(rhs.horizontalRange),
            let vRange = verticalRange.intersected(rhs.verticalRange)
        else {
            return nil
        }
        return .init(horizontalRange: hRange, verticalRange: vRange)
    }

    public static let zero: Self = .init()

    public var normalized: Self {
        let insets = insets
        return .init(
            origin: .init(x: insets.left, y: insets.bottom),
            size: .init(width: insets.right - insets.left, height: insets.top - insets.bottom))
    }

    public init(horizontalRange: Range, verticalRange: Range) {
        self = .init(
            origin: .init(
                x: horizontalRange.location,
                y: verticalRange.location
            ),
            size: .init(
                width: horizontalRange.length,
                height: verticalRange.length
            )
        )
    }

    public var positions: RegionPositions {
        .init(self)
    }

    public func contains(_ rhs: Point) -> Bool {
        let sumX = origin.x + size.width
        let minX = min(origin.x, sumX)
        let maxX = max(origin.x, sumX)
        let sumY = origin.y + size.height
        let minY = min(origin.y, sumY)
        let maxY = max(origin.y, sumY)

        return minX <= rhs.x && rhs.x < maxX && minY <= rhs.y && rhs.y < maxY
    }
}

public func + (lhs: Region, rhs: RegionInsets) -> Region {
    let left = lhs.left + rhs.left
    let right = lhs.right + rhs.right
    let bottom = lhs.bottom + rhs.bottom
    let top = lhs.top + rhs.top

    return .init(
        origin: .init(x: left, y: bottom), size: .init(width: right - left, height: top - bottom))
}

public func - (lhs: Region, rhs: RegionInsets) -> Region {
    let left = lhs.left - rhs.left
    let right = lhs.right - rhs.right
    let bottom = lhs.bottom - rhs.bottom
    let top = lhs.top - rhs.top

    return .init(
        origin: .init(x: left, y: bottom), size: .init(width: right - left, height: top - bottom))
}

public func += (lhs: inout Region, rhs: RegionInsets) {
    let left = lhs.left + rhs.left
    let right = lhs.right + rhs.right
    let bottom = lhs.bottom + rhs.bottom
    let top = lhs.top + rhs.top

    lhs.origin = .init(x: left, y: bottom)
    lhs.size = .init(width: right - left, height: top - bottom)
}

public func -= (lhs: inout Region, rhs: RegionInsets) {
    let left = lhs.left - rhs.left
    let right = lhs.right - rhs.right
    let bottom = lhs.bottom - rhs.bottom
    let top = lhs.top - rhs.top

    lhs.origin = .init(x: left, y: bottom)
    lhs.size = .init(width: right - left, height: top - bottom)
}

public func + (lhs: Region, rhs: Point) -> Region {
    return .init(origin: .init(x: lhs.origin.x + rhs.x, y: lhs.origin.y + rhs.y), size: lhs.size)
}

public func += (lhs: inout Region, rhs: Point) {
    lhs.origin = .init(x: lhs.origin.x + rhs.x, y: lhs.origin.y + rhs.y)
}
