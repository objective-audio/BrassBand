import BrassBand
import Testing

struct RegionInsetsTests {
    @Test func isEqual() {
        let insetsA1 = RegionInsets(left: 1.0, right: 2.0, bottom: 3.0, top: 4.0)
        let insetsA2 = RegionInsets(left: 1.0, right: 2.0, bottom: 3.0, top: 4.0)
        let insetsDiffLeft = RegionInsets(left: 1.5, right: 2.0, bottom: 3.0, top: 4.0)
        let insetsDiffRight = RegionInsets(left: 1.0, right: 2.5, bottom: 3.0, top: 4.0)
        let insetsDiffBottom = RegionInsets(left: 1.0, right: 2.0, bottom: 3.5, top: 4.0)
        let insetsDiffTop = RegionInsets(left: 1.0, right: 2.0, bottom: 3.0, top: 4.5)

        #expect(insetsA1 == insetsA1)
        #expect(insetsA1 == insetsA2)

        #expect(insetsA1 != insetsDiffLeft)
        #expect(insetsA1 != insetsDiffRight)
        #expect(insetsA1 != insetsDiffBottom)
        #expect(insetsA1 != insetsDiffTop)
    }

    @Test func zero() {
        #expect(RegionInsets.zero.left == 0.0)
        #expect(RegionInsets.zero.right == 0.0)
        #expect(RegionInsets.zero.bottom == 0.0)
        #expect(RegionInsets.zero.top == 0.0)
    }
}
