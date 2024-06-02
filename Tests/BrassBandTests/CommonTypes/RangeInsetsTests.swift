import BrassBand
import Testing

struct RangeInsetsTests {
    @Test func isEqual() {
        let insets1 = RangeInsets(min: 1.0, max: 2.0)
        let insets2 = RangeInsets(min: 1.0, max: 2.0)
        let insets3 = RangeInsets(min: 1.1, max: 2.0)
        let insets4 = RangeInsets(min: 1.0, max: 2.1)
        let insets5 = RangeInsets(min: 1.1, max: 2.1)
        let zero_insets1 = RangeInsets(min: 0.0, max: 0.0)
        let zero_insets2 = RangeInsets(min: 0.0, max: 0.0)

        #expect(insets1 == insets2)
        #expect(insets1 != insets3)
        #expect(insets1 != insets4)
        #expect(insets1 != insets5)
        #expect(zero_insets1 == zero_insets2)
    }

    @Test func zero() {
        #expect(RangeInsets.zero.min == 0.0)
        #expect(RangeInsets.zero.max == 0.0)
    }
}
