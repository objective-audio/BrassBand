import Testing

@testable import BrassBand

struct AlphaTests {
    @Test func initWithValue() {
        #expect(Alpha(value: 0).value == 0)
        #expect(Alpha(value: 0.5).value == 0.5)
        #expect(Alpha(value: 1).value == 1)
        #expect(Alpha(value: -1).value == 0)
    }

    @Test func zero() {
        #expect(Alpha.zero.value == 0)
    }

    @Test func one() {
        #expect(Alpha.one.value == 1)
    }
}
