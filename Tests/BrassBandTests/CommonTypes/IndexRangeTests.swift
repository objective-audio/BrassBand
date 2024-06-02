import Testing

@testable import BrassBand

struct IndexRangeTests {
    @Test func equal() {
        let indexRange1a = IndexRange(index: 0, length: 1)
        let indexRange1b = IndexRange(index: 0, length: 1)
        let indexRange2 = IndexRange(index: 1, length: 1)
        let indexRange3 = IndexRange(index: 0, length: 2)

        #expect(indexRange1a == indexRange1a)
        #expect(indexRange1a == indexRange1b)
        #expect(indexRange1a != indexRange2)
        #expect(indexRange1a != indexRange3)
    }

    @Test func contains() {
        let indexRange = IndexRange(index: 1, length: 2)

        #expect(!indexRange.contains(0))
        #expect(indexRange.contains(1))
        #expect(indexRange.contains(2))
        #expect(!indexRange.contains(3))
    }

    @Test func next() {
        #expect(IndexRange(index: 1, length: 2).next == 3)
    }

    @Test func zero() {
        #expect(IndexRange.zero == IndexRange(index: 0, length: 0))
    }
}
