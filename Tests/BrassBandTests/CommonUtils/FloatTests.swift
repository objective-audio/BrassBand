import Testing

@testable import BrassBand

struct FloatTests {
    @Test func pi2() {
        #expect(Float.pi2.isApproximatelyEqual(to: 1.5707963, absoluteTolerance: 0.001))
    }
}
