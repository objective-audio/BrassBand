import BrassBand
import Testing

struct UIntRangeTests {
    @Test func isEqual() {
        let range1_2a = UIntRange(location: 1, length: 2)
        let range1_2b = UIntRange(location: 1, length: 2)
        let range1_3 = UIntRange(location: 1, length: 3)
        let range2_2 = UIntRange(location: 2, length: 2)

        #expect(range1_2a == range1_2a)
        #expect(range1_2a == range1_2b)
        #expect(range1_2a != range1_3)
        #expect(range1_2a != range2_2)
    }

    @Test func properties() {
        let range = UIntRange(location: 1, length: 2)

        #expect(range.min == 1)
        #expect(range.max == 3)
    }

    @Test func zero() {
        #expect(UIntRange.zero.location == 0)
        #expect(UIntRange.zero.length == 0)
    }
}
