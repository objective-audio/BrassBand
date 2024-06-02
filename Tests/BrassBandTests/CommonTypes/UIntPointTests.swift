import BrassBand
import Testing

struct UIntPointTests {
    @Test func isEqual() {
        let origin1_2a = UIntPoint(x: 1, y: 2)
        let origin1_2b = UIntPoint(x: 1, y: 2)
        let origin1_3 = UIntPoint(x: 1, y: 3)
        let origin2_2 = UIntPoint(x: 2, y: 2)

        #expect(origin1_2a == origin1_2a)
        #expect(origin1_2a == origin1_2b)
        #expect(origin1_2a != origin1_3)
        #expect(origin1_2a != origin2_2)
    }

    @Test func zero() {
        #expect(UIntPoint.zero.x == 0)
        #expect(UIntPoint.zero.y == 0)
    }

    @Test func simd2() {
        let simd2 = UIntPoint(x: 1, y: 2).simd2

        #expect(simd2.x == 1.0)
        #expect(simd2.y == 2.0)
    }
}
