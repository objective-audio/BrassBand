import BrassBand
import Testing

struct RangeTests {
    @Test func isEqual() {
        let range1 = Range(location: 1.0, length: 2.0)
        let range2 = Range(location: 1.0, length: 2.0)
        let range3 = Range(location: 1.1, length: 2.0)
        let range4 = Range(location: 1.0, length: 2.1)
        let range5 = Range(location: 1.1, length: 2.1)
        let zeroRange1 = Range(location: 0.0, length: 0.0)
        let zeroRange2 = Range(location: 0.0, length: 0.0)

        #expect(range1 == range2)
        #expect(range1 != range3)
        #expect(range1 != range4)
        #expect(range1 != range5)
        #expect(zeroRange1 == zeroRange2)
    }

    @Test func properties() {
        do {
            let range = Range(location: 1.0, length: 2.0)

            #expect(range.min == 1.0)
            #expect(range.max == 3.0)
            #expect(range.insets == RangeInsets(min: 1.0, max: 3.0))
        }

        do {
            let range = Range(location: 3.0, length: -1.0)

            #expect(range.min == 2.0)
            #expect(range.max == 3.0)
            #expect(range.insets == RangeInsets(min: 2.0, max: 3.0))
        }
    }

    @Test func rangeZero() {
        #expect(Range.zero.location == 0.0)
        #expect(Range.zero.length == 0.0)
    }

    @Test(arguments: [
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: -0.5, max: 0.25),
            expected: Range(location: 0.5, length: 2.75)
        ),
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: 0.5, max: -0.25),
            expected: Range(location: 1.5, length: 1.25)
        ),
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: 2.5, max: 0.0),
            expected: Range(location: 3.0, length: 0.5)
        ),
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: 0.0, max: -2.5),
            expected: Range(location: 0.5, length: 0.5)
        ),
    ])
    func addWithInsets(range: Range, insets: RangeInsets, expected: Range) {
        #expect(range + insets == expected)
        #expect(
            {
                var range = range
                range += insets
                return range
            }() == expected)
    }

    @Test(arguments: [
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: -0.5, max: 0.25),
            expected: Range(location: 1.5, length: 1.25)
        ),
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: 0.5, max: -0.25),
            expected: Range(location: 0.5, length: 2.75)
        ),
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: -2.5, max: 0.0),
            expected: Range(location: 3.0, length: 0.5)
        ),
        (
            range: Range(location: 1.0, length: 2.0), insets: RangeInsets(min: 0.0, max: 2.5),
            expected: Range(location: 0.5, length: 0.5)
        ),
    ])
    func subtractWithInsets(range: Range, insets: RangeInsets, expected: Range) {
        #expect(range - insets == expected)
        #expect(
            {
                var range = range
                range -= insets
                return range
            }() == expected)
    }

    @Test func combined() {
        #expect(
            Range(location: 0, length: 1).combined(.init(location: 2, length: 1))
                == Range(location: 0, length: 3))
        #expect(
            Range(location: -1, length: 2).combined(.init(location: 0, length: 3))
                == Range(location: -1, length: 4))
        #expect(Range.zero.combined(.zero) == .zero)
    }

    @Test(arguments: [
        (
            lhs: Range(location: 0, length: 1), rhs: Range(location: 0, length: 1),
            expected: Range(location: 0, length: 1)
        ),
        (
            lhs: Range(location: 0, length: 1), rhs: Range(location: 1, length: 1),
            expected: Range(location: 1, length: 0)
        ),
        (
            lhs: Range(location: 0, length: 2), rhs: Range(location: 1, length: 2),
            expected: Range(location: 1, length: 1)
        ),
        (lhs: Range(location: 0, length: 1), rhs: Range(location: 2, length: 1), expected: nil),
    ])
    func intersected(lhs: Range, rhs: Range, expected: Range?) {
        #expect(lhs.intersected(rhs) == expected)
    }

    @Test func initWithUintRange() {
        #expect(Range(UIntRange(location: 2, length: 4)) == Range(location: 2.0, length: 4.0))
    }

    @Test(arguments: [
        (min: Float(-1.0), expected: Range(location: -1.0, length: 3.0)),
        (min: Float(0.0), expected: Range(location: 0.0, length: 2.0)),
        (min: Float(1.0), expected: Range(location: 1.0, length: 1.0)),
        (min: Float(2.0), expected: Range(location: 2.0, length: 0.0)),
        (min: Float(3.0), expected: Range(location: 3.0, length: 0.0)),
    ])
    func setMin(_ min: Float, expected: Range) {
        var range = Range(location: 0.0, length: 2.0)
        range.min = min
        #expect(range == expected)
    }

    @Test(arguments: [
        (max: Float(3.0), expected: Range(location: 0.0, length: 3.0)),
        (max: Float(2.0), expected: Range(location: 0.0, length: 2.0)),
        (max: Float(1.0), expected: Range(location: 0.0, length: 1.0)),
        (max: Float(0.0), expected: Range(location: 0.0, length: 0.0)),
        (max: Float(-1.0), expected: Range(location: -1.0, length: 0.0)),
    ])
    func setMax(_ max: Float, expected: Range) {
        var range = Range(location: 0.0, length: 2.0)
        range.max = max
        #expect(range == expected)
    }
}
