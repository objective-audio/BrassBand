import BrassBand
import CoreGraphics
import Testing

struct PointTests {
    @Test func initWithNoParams() {
        let point = Point()

        #expect(point.x == 0.0)
        #expect(point.y == 0.0)
    }

    @Test func initWithParams() {
        let point = Point(x: 1.0, y: 2.0)

        #expect(point.x == 1.0)
        #expect(point.y == 2.0)
    }

    @Test func initWithRepeating() {
        let point = Point(repeating: 0.5)

        #expect(point.x == 0.5)
        #expect(point.y == 0.5)
    }

    @Test func initWithSimd2() {
        let point = Point(simd2: .init(3.0, 4.0))

        #expect(point.x == 3.0)
        #expect(point.y == 4.0)
    }

    @Test func initWithUIntPoint() {
        #expect(Point(UIntPoint(x: 1, y: 2)) == Point(x: 1.0, y: 2.0))
    }

    @Test func initWithCGPoint() {
        let point = Point(CGPointMake(1.0, 2.0))

        #expect(point.x == 1.0)
        #expect(point.y == 2.0)
    }

    @Test func isEqual() {
        let point1 = Point(x: 1.0, y: 2.0)
        let point2 = Point(x: 1.0, y: 2.0)
        let point3 = Point(x: 1.1, y: 2.0)
        let point4 = Point(x: 1.0, y: 2.1)
        let point5 = Point(x: 1.1, y: 2.1)
        let zero_point1 = Point(x: 0.0, y: 0.0)
        let zero_point2 = Point(x: 0.0, y: 0.0)

        #expect(point1 == point2)
        #expect(point1 != point3)
        #expect(point1 != point4)
        #expect(point1 != point5)
        #expect(zero_point1 == zero_point2)
    }

    @Test func add() {
        let point1 = Point(x: 1.0, y: 2.0)
        let point2 = Point(x: 3.0, y: 4.0)

        let point = point1 + point2

        #expect(point.x.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
        #expect(point.y.isApproximatelyEqual(to: 6.0, absoluteTolerance: 0.001))
    }

    @Test func subtract() {
        let point1 = Point(x: 4.0, y: 3.0)
        let point2 = Point(x: 1.0, y: 2.0)

        let point = point1 - point2

        #expect(point.x.isApproximatelyEqual(to: 3.0, absoluteTolerance: 0.001))
        #expect(point.y.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func addToItself() {
        var point1 = Point(x: 1.0, y: 2.0)
        let point2 = Point(x: 3.0, y: 4.0)

        point1 += point2

        #expect(point1.x.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
        #expect(point1.y.isApproximatelyEqual(to: 6.0, absoluteTolerance: 0.001))
    }

    @Test func subtractToItself() {
        var point1 = Point(x: 4.0, y: 3.0)
        let point2 = Point(x: 1.0, y: 2.0)

        point1 -= point2

        #expect(point1.x.isApproximatelyEqual(to: 3.0, absoluteTolerance: 0.001))
        #expect(point1.y.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func zero() {
        #expect(Point.zero.x == 0.0)
        #expect(Point.zero.y == 0.0)
    }

    @Test func hasValue() {
        #expect(Point(x: 1.0, y: 0.0).hasValue)
        #expect(Point(x: 0.0, y: 1.0).hasValue)

        #expect(!Point.zero.hasValue)
    }

    @Test func distanceFrom() {
        #expect(
            Point.zero.distance(from: .init(x: 1.0, y: 1.0)).isApproximatelyEqual(
                to: sqrtf(2.0), absoluteTolerance: 0.001))
        #expect(
            Point.zero.distance(from: .init(x: 2.0, y: 1.0)).isApproximatelyEqual(
                to: sqrtf(powf(2.0 - 0.0, 2.0) + powf(1.0 - 0.0, 2.0)), absoluteTolerance: 0.001))
        #expect(
            Point(x: -1.0, y: -2.0).distance(from: .init(x: 2.0, y: 1.0)).isApproximatelyEqual(
                to: sqrtf(powf(2.0 + 1.0, 2.0) + powf(1.0 + 2.0, 2.0)), absoluteTolerance: 0.001))
    }

    @Test func cgPoint() {
        #expect(Point(x: 1.0, y: 2.0).cgPoint == CGPoint(x: 1.0, y: 2.0))
    }
}
