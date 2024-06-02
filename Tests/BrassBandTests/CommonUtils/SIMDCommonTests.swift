import BrassBand
import Testing

struct SIMDCommonTests {
    @Test func simd2ToSimd4() {
        let value = SIMD2<Float>(16.0, 32.0)

        #expect(value.simd4 == .init(16.0, 32.0, 0.0, 1.0))
    }

    @Test func simd4ToSimd2() {
        let value = SIMD4<Float>(1.0, 2.0, 4.0, 8.0)

        #expect(value.simd2 == .init(1.0, 2.0))
    }
}
