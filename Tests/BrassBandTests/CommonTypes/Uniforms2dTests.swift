import BrassBand
import Testing

struct Uniforms2dTests {
    @Test func equal() {
        func makeTestMatrix(_ value: Float) -> simd_float4x4 {
            float4x4.translation(x: value, y: value)
        }

        #expect(
            Uniforms2d(
                matrix: makeTestMatrix(1.0), color: .init(repeating: 2.0),
                isMeshColorUsed: false)
                == Uniforms2d(
                    matrix: makeTestMatrix(1.0), color: .init(repeating: 2.0),
                    isMeshColorUsed: false))
        #expect(
            Uniforms2d(
                matrix: makeTestMatrix(1.0), color: .init(repeating: 2.0),
                isMeshColorUsed: false)
                != Uniforms2d(
                    matrix: makeTestMatrix(4.0), color: .init(repeating: 2.0),
                    isMeshColorUsed: false))
        #expect(
            Uniforms2d(
                matrix: makeTestMatrix(1.0), color: .init(repeating: 2.0),
                isMeshColorUsed: false)
                != Uniforms2d(
                    matrix: makeTestMatrix(1.0), color: .init(repeating: 4.0),
                    isMeshColorUsed: false))
        #expect(
            Uniforms2d(
                matrix: makeTestMatrix(1.0), color: .init(repeating: 2.0),
                isMeshColorUsed: false)
                != Uniforms2d(
                    matrix: makeTestMatrix(1.0), color: .init(repeating: 2.0),
                    isMeshColorUsed: true))
    }
}
