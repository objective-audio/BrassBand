import BrassBand
import Testing

struct RegionTests {
    @Test func isEqual() {
        let origin_a1 = Point(x: 1.0, y: 2.0)
        let origin_a2 = Point(x: 1.0, y: 2.0)
        let origin_b = Point(x: 3.0, y: 4.0)

        let size_a1 = Size(width: 5.0, height: 6.0)
        let size_a2 = Size(width: 5.0, height: 6.0)
        let size_b = Size(width: 7.0, height: 8.0)

        let region_a1_a1 = Region(origin: origin_a1, size: size_a1)
        let region_a1_a2 = Region(origin: origin_a1, size: size_a2)
        let region_a2_a1 = Region(origin: origin_a2, size: size_a1)
        let region_a2_a2 = Region(origin: origin_a2, size: size_a2)
        let region_b = Region(origin: origin_b, size: size_b)

        #expect(region_a1_a1 == region_a1_a1)
        #expect(region_a1_a1 == region_a1_a2)
        #expect(region_a1_a1 == region_a2_a1)
        #expect(region_a1_a1 == region_a2_a2)
        #expect(region_a1_a1 != region_b)
    }

    @Test func contains() {
        let region = Region(origin: .init(x: 0.0, y: -1.0), size: .init(width: 1.0, height: 2.0))

        #expect(region.contains(.init(x: 0.0, y: 0.0)))
        #expect(region.contains(.init(x: 0.0, y: -1.0)))
        #expect(region.contains(.init(x: 0.999, y: 0.0)))
        #expect(region.contains(.init(x: 0.0, y: 0.999)))

        #expect(!region.contains(.init(x: -0.0001, y: 0.0)))
        #expect(!region.contains(.init(x: 0.0, y: -1.001)))
        #expect(!region.contains(.init(x: 1.0, y: 0.0)))
        #expect(!region.contains(.init(x: 0.0, y: 1.0)))
    }

    @Test func initWithSimd4() {
        let region = Region(simd4: .init(1.0, 2.0, 3.0, 4.0))

        #expect(region.origin.x == 1.0)
        #expect(region.origin.y == 2.0)
        #expect(region.size.width == 3.0)
        #expect(region.size.height == 4.0)
    }

    @Test func properties() {
        do {
            let region = Region(origin: Point(x: 0.0, y: 1.0), size: Size(width: 2.0, height: 3.0))

            #expect(region.left == 0.0)
            #expect(region.right == 2.0)
            #expect(region.bottom == 1.0)
            #expect(region.top == 4.0)
            #expect(region.insets.left.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
            #expect(region.insets.right.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
            #expect(region.insets.bottom.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
            #expect(region.insets.top.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
            #expect(region.center.x.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
            #expect(region.center.y.isApproximatelyEqual(to: 2.5, absoluteTolerance: 0.001))
        }

        do {
            let region = Region(
                origin: Point(x: 4.0, y: 5.0), size: Size(width: -7.0, height: -6.0))

            #expect(region.left == -3.0)
            #expect(region.right == 4.0)
            #expect(region.bottom == -1.0)
            #expect(region.top == 5.0)
        }
    }

    @Test func regionZero() {
        #expect(Region.zero.origin.x == 0.0)
        #expect(Region.zero.origin.y == 0.0)
        #expect(Region.zero.size.width == 0.0)
        #expect(Region.zero.size.height == 0.0)
    }

    @Test func initWithCenter() {
        do {
            let region = Region(center: .zero, size: .init(width: 2.0, height: 4.0))

            #expect(region.origin.x == -1.0)
            #expect(region.origin.y == -2.0)
            #expect(region.size.width == 2.0)
            #expect(region.size.height == 4.0)
        }

        do {
            let region = Region(center: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 4.0))

            #expect(region.origin.x == 0.0)
            #expect(region.origin.y == 1.0)
            #expect(region.size.width == 2.0)
            #expect(region.size.height == 4.0)
        }
    }

    @Test func addInsets() {
        let source = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))
        let added = source + RegionInsets(left: -1.0, right: 2.0, bottom: -3.0, top: 4.0)

        #expect(
            added == Region(origin: .init(x: 0.0, y: -1.0), size: .init(width: 6.0, height: 11.0)))
    }

    @Test func subtractInsets() {
        let source = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))
        let subtracted = source - RegionInsets(left: -1.0, right: 2.0, bottom: -3.0, top: 4.0)

        #expect(
            subtracted
                == Region(origin: .init(x: 2.0, y: 5.0), size: .init(width: 0.0, height: -3.0))
        )
    }

    @Test func addToItselfWithInsets() {
        var region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))
        region += RegionInsets(left: -1.0, right: 2.0, bottom: -3.0, top: 4.0)

        #expect(
            region == Region(origin: .init(x: 0.0, y: -1.0), size: .init(width: 6.0, height: 11.0)))
    }

    @Test func subtractToItselfWithInsets() {
        var region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))
        region -= RegionInsets(left: -1.0, right: 2.0, bottom: -3.0, top: 4.0)

        #expect(
            region == Region(origin: .init(x: 2.0, y: 5.0), size: .init(width: 0.0, height: -3.0))
        )
    }

    @Test func normalized() {
        let region1 = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))
        let region2 = Region(origin: .init(x: 4.0, y: 6.0), size: .init(width: -3.0, height: -4.0))

        #expect(region1.normalized == region1)
        #expect(region2.normalized == region1)
    }

    @Test func combined() {
        #expect(
            Region(origin: .init(x: 0.0, y: 1.0), size: .init(width: 2.0, height: 3.0)).combined(
                Region(origin: .init(x: 4.0, y: 5.0), size: .init(width: 6.0, height: 7.0)))
                == Region(origin: .init(x: 0.0, y: 1.0), size: .init(width: 10.0, height: 11.0))
        )
    }

    @Test func intersected() {
        #expect(
            Region(origin: .init(x: 0.0, y: 1.0), size: .init(width: 2.0, height: 3.0)).intersected(
                Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 4.0, height: 5.0)))
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 1.0, height: 2.0))
        )
    }

    @Test func initWithUIntRegion() {
        #expect(
            Region(UIntRegion(origin: .init(x: 1, y: 2), size: .init(width: 4, height: 8)))
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 4.0, height: 8.0)))
    }

    @Test func hasValue() {
        #expect(Region(origin: .init(x: 1.0, y: 0.0), size: .zero).hasValue)
        #expect(Region(origin: .init(x: 0.0, y: 1.0), size: .zero).hasValue)
        #expect(Region(origin: .zero, size: .init(width: 1.0, height: 0.0)).hasValue)
        #expect(Region(origin: .zero, size: .init(width: 0.0, height: 1.0)).hasValue)
        #expect(!Region.zero.hasValue)
    }

    @Test func positions() {
        let region = Region(origin: .init(x: 0.0, y: 2.0), size: .init(width: 4.0, height: 8.0))
        let positions = region.positions

        #expect(positions[0].x == region.left)
        #expect(positions[0].y == region.bottom)
        #expect(positions[1].x == region.right)
        #expect(positions[1].y == region.bottom)
        #expect(positions[2].x == region.left)
        #expect(positions[2].y == region.top)
        #expect(positions[3].x == region.right)
        #expect(positions[3].y == region.top)
    }

    @Test func cgRect() {
        let region = Region(origin: .init(x: 0.0, y: 2.0), size: .init(width: 4.0, height: 8.0))
        #expect(region.cgRect == CGRect(x: 0.0, y: 2.0, width: 4.0, height: 8.0))
    }

    @Test func horizontalRange() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(region.horizontalRange.location == 1.0)
        #expect(region.horizontalRange.length == 3.0)

        var newRegion = region
        newRegion.horizontalRange = Range(location: 2.0, length: 3.0)
        #expect(newRegion.origin.x == 2.0)
        #expect(newRegion.size.width == 3.0)
    }

    @Test func verticalRange() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(region.verticalRange.location == 2.0)
        #expect(region.verticalRange.length == 4.0)

        var newRegion = region
        newRegion.verticalRange = Range(location: 3.0, length: 4.0)
        #expect(newRegion.origin.y == 3.0)
        #expect(newRegion.size.height == 4.0)
    }

    @Test func left() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(region.left == 1.0)

        var newRegion = region
        newRegion.left = 2.0
        #expect(newRegion.origin.x == 2.0)
        #expect(newRegion.size.width == 2.0)
    }

    @Test func right() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(region.right == 4.0)

        var newRegion = region
        newRegion.right = 5.0
        #expect(newRegion.size.width == 4.0)
    }

    @Test func bottom() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(region.bottom == 2.0)

        var newRegion = region
        newRegion.bottom = 3.0
        #expect(newRegion.origin.y == 3.0)
        #expect(newRegion.size.height == 3.0)
    }

    @Test func top() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(region.top == 6.0)

        var newRegion = region
        newRegion.top = 7.0
        #expect(newRegion.size.height == 5.0)
    }

    @Test func addPoint() {
        let region = Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))
        let point = Point(x: 2.0, y: 3.0)

        let added = region + point
        #expect(added.origin.x == 3.0)
        #expect(added.origin.y == 5.0)
        #expect(added.size.width == 3.0)
        #expect(added.size.height == 4.0)

        var newRegion = region
        newRegion += point
        #expect(newRegion.origin.x == 3.0)
        #expect(newRegion.origin.y == 5.0)
        #expect(newRegion.size.width == 3.0)
        #expect(newRegion.size.height == 4.0)
    }
}
