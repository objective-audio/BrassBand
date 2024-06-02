import BrassBand
import Testing

struct SizeTests {
    @Test func initial() {
        let size = Size()

        #expect(size.width == 0.0)
        #expect(size.height == 0.0)
    }

    @Test func initWithParams() {
        let size = Size(width: 1.0, height: 2.0)

        #expect(size.width == 1.0)
        #expect(size.height == 2.0)
    }

    @Test func initWithRepeating() {
        let size = Size(repeating: 4.0)

        #expect(size.width == 4.0)
        #expect(size.height == 4.0)
    }

    @Test func initWithSimd2() {
        let size = Size(simd2: .init(8.0, 16.0))

        #expect(size.width == 8.0)
        #expect(size.height == 16.0)
    }

    @Test func isEqual() {
        let size1 = Size(width: 1.0, height: 2.0)
        let size2 = Size(width: 1.0, height: 2.0)
        let size3 = Size(width: 1.1, height: 2.0)
        let size4 = Size(width: 1.0, height: 2.1)
        let size5 = Size(width: 1.1, height: 2.1)
        let zero_size1 = Size(width: 0.0, height: 0.0)
        let zero_size2 = Size(width: 0.0, height: 0.0)

        #expect(size1 == size2)
        #expect(size1 != size3)
        #expect(size1 != size4)
        #expect(size1 != size5)
        #expect(zero_size1 == zero_size2)
    }

    @Test func zero() {
        #expect(Size.zero.width == 0.0)
        #expect(Size.zero.height == 0.0)
    }

    @Test func initWithUintSize() {
        #expect(Size(UIntSize(width: 4, height: 8)) == Size(width: 4.0, height: 8.0))
    }

    @Test func hasValue() {
        #expect(Size(width: 1.0, height: 0.0).hasValue)
        #expect(Size(width: 0.0, height: 1.0).hasValue)

        #expect(!Size.zero.hasValue)
    }

    @Test func add() {
        let size1 = Size(width: 1.0, height: 2.0)
        let size2 = Size(width: 3.0, height: 4.0)

        let size = size1 + size2

        #expect(size.width.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
        #expect(size.height.isApproximatelyEqual(to: 6.0, absoluteTolerance: 0.001))
    }

    @Test func subtract() {
        let size1 = Size(width: 4.0, height: 3.0)
        let size2 = Size(width: 1.0, height: 2.0)

        let size = size1 - size2

        #expect(size.width.isApproximatelyEqual(to: 3.0, absoluteTolerance: 0.001))
        #expect(size.height.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func multiply() {
        let size1 = Size(width: 1.0, height: 2.0)

        let size = size1 * 2.0

        #expect(size.width.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
        #expect(size.height.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
    }

    @Test func divide() {
        let size1 = Size(width: 1.0, height: 2.0)

        let size = size1 / 2.0

        #expect(size.width.isApproximatelyEqual(to: 0.5, absoluteTolerance: 0.001))
        #expect(size.height.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func addToItself() {
        var size1 = Size(width: 1.0, height: 2.0)
        let size2 = Size(width: 3.0, height: 4.0)

        size1 += size2

        #expect(size1.width.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
        #expect(size1.height.isApproximatelyEqual(to: 6.0, absoluteTolerance: 0.001))
    }

    @Test func subtractToItself() {
        var size1 = Size(width: 4.0, height: 3.0)
        let size2 = Size(width: 1.0, height: 2.0)

        size1 -= size2

        #expect(size1.width.isApproximatelyEqual(to: 3.0, absoluteTolerance: 0.001))
        #expect(size1.height.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func multiplyToItself() {
        var size = Size(width: 1.0, height: 2.0)

        size *= 2.0

        #expect(size.width.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
        #expect(size.height.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
    }

    @Test func divideToItself() {
        var size = Size(width: 1.0, height: 2.0)

        size /= 2.0

        #expect(size.width.isApproximatelyEqual(to: 0.5, absoluteTolerance: 0.001))
        #expect(size.height.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func cgSize() {
        let size = Size(width: 8.0, height: 16.0)

        #expect(size.cgSize == CGSize(width: 8.0, height: 16.0))
    }
}
