import BrassBand
import Testing

struct MatrixTests {
    @Test func scale() {
        let matrix = simd_float4x4.scaling(scale: .init(width: 2.0, height: 4.0))

        #expect(
            matrix
                == .init(
                    .init(2.0, 0.0, 0.0, 0.0), .init(0.0, 4.0, 0.0, 0.0), .init(0.0, 0.0, 1.0, 0.0),
                    .init(0.0, 0.0, 0.0, 1.0))
        )

        let v = matrix * SIMD4<Float>(1.0, 2.0, 0.0, 1.0)

        #expect(v.x.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
        #expect(v.y.isApproximatelyEqual(to: 8.0, absoluteTolerance: 0.001))
    }

    @Test func translation() {
        let matrix = simd_float4x4.translation(position: .init(x: 3.0, y: -1.0))

        #expect(
            matrix
                == .init(
                    .init(1.0, 0.0, 0.0, 0.0), .init(0.0, 1.0, 0.0, 0.0), .init(0.0, 0.0, 1.0, 0.0),
                    .init(3.0, -1.0, 0.0, 1.0))
        )

        let v = matrix * SIMD4<Float>(1.0, 0.0, 0.0, 1.0)

        #expect(v.x.isApproximatelyEqual(to: 4.0, absoluteTolerance: 0.001))
        #expect(v.y.isApproximatelyEqual(to: -1.0, absoluteTolerance: 0.001))
    }

    @Test func rotation() {
        let matrix = simd_float4x4.rotation(angle: .init(degrees: 90.0))
        let v = matrix * SIMD4<Float>(1.0, 0.0, 0.0, 1.0)
        #expect(v.x.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        #expect(v.y.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    @Test func ortho() {
        let matrix = simd_float4x4.ortho(
            left: 0.0, right: 100.0, bottom: -20.0, top: 20.0, near: -1.0, far: 1.0)

        do {
            let v = matrix * SIMD4<Float>(0.0, 0.0, 0.0, 1.0)

            #expect(v.x.isApproximatelyEqual(to: -1.0, absoluteTolerance: 0.001))
            #expect(v.y.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        }

        do {
            let v = matrix * SIMD4<Float>(100.0, 20.0, 0.0, 1.0)

            #expect(v.x.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
            #expect(v.y.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
        }
    }
}
