import BrassBand
import Testing

struct TransformerTests {
    @Test func easeInSineTransformer() {
        let transformer = Transformer.easeInSine.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.019, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.076, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.169, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.293, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.444, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.617, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.805, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutSineTransformer() {
        let transformer = Transformer.easeOutSine.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.195, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.383, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.556, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.707, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.831, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.924, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.981, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutSineTransformer() {
        let transformer = Transformer.easeInOutSine.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.038, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.146, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.309, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.500, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.691, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.854, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.962, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInQuadTransformer() {
        let transformer = Transformer.easeInQuad.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.0156, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.0625, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.14, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.25, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.39, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.562, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.765, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutQuadTransformer() {
        let transformer = Transformer.easeOutQuad.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.234, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.437, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.609, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.75, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.859, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.937, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.984, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutQuadTransformer() {
        let transformer = Transformer.easeInOutQuad.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.031, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.125, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.281, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.5, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.718, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.875, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.968, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInCubicTransformer() {
        let transformer = Transformer.easeInCubic.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.002, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.016, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.053, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.125, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.244, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.422, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.670, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutCubicTransformer() {
        let transformer = Transformer.easeOutCubic.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.33, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.578, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.756, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.875, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.947, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.984, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.998, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutCubicTransformer() {
        let transformer = Transformer.easeInOutCubic.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.008, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.062, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.211, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.5, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.789, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.938, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.992, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInQuartTransformer() {
        let transformer = Transformer.easeInQuart.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.000, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.004, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.020, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.062, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.153, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.316, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.586, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutQuartTransformer() {
        let transformer = Transformer.easeOutQuart.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.414, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.684, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.847, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.938, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.980, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.996, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 1.000, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutQuartTransformer() {
        let transformer = Transformer.easeInOutQuart.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.002, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.031, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.158, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.500, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.842, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.969, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.998, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInQuintTransformer() {
        let transformer = Transformer.easeInQuint.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.000, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.001, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.007, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.031, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.095, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.237, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.513, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutQuintTransformer() {
        let transformer = Transformer.easeOutQuint.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.487, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.763, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.905, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.969, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.993, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.999, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutQuintTransformer() {
        let transformer = Transformer.easeInOutQuint.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.000, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.016, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.119, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.500, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.881, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.984, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 1.000, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInExpoTransformer() {
        let transformer = Transformer.easeInExpo.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.002, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.005, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.013, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.031, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.074, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.176, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.420, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutExpoTransformer() {
        let transformer = Transformer.easeOutExpo.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.580, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.824, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.926, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.969, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.987, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.995, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.998, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutExpoTransformer() {
        let transformer = Transformer.easeInOutExpo.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.003, absoluteTolerance: 0.001))
        #expect(transformer(0.25).isApproximatelyEqual(to: 0.016, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.088, absoluteTolerance: 0.001))
        #expect(transformer(0.5).isApproximatelyEqual(to: 0.500, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.912, absoluteTolerance: 0.001))
        #expect(transformer(0.75).isApproximatelyEqual(to: 0.984, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.997, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInCircTransformer() {
        let transformer = Transformer.easeInCirc.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.008, absoluteTolerance: 0.001))
        #expect(transformer(0.250).isApproximatelyEqual(to: 0.032, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.073, absoluteTolerance: 0.001))
        #expect(transformer(0.500).isApproximatelyEqual(to: 0.134, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.219, absoluteTolerance: 0.001))
        #expect(transformer(0.750).isApproximatelyEqual(to: 0.339, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.516, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeOutCircTransformer() {
        let transformer = Transformer.easeOutCirc.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.484, absoluteTolerance: 0.001))
        #expect(transformer(0.250).isApproximatelyEqual(to: 0.661, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.781, absoluteTolerance: 0.001))
        #expect(transformer(0.500).isApproximatelyEqual(to: 0.866, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.927, absoluteTolerance: 0.001))
        #expect(transformer(0.750).isApproximatelyEqual(to: 0.968, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.992, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func easeInOutCircTransformer() {
        let transformer = Transformer.easeInOutCirc.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.125).isApproximatelyEqual(to: 0.016, absoluteTolerance: 0.001))
        #expect(transformer(0.250).isApproximatelyEqual(to: 0.067, absoluteTolerance: 0.001))
        #expect(transformer(0.375).isApproximatelyEqual(to: 0.169, absoluteTolerance: 0.001))
        #expect(transformer(0.500).isApproximatelyEqual(to: 0.500, absoluteTolerance: 0.001))
        #expect(transformer(0.625).isApproximatelyEqual(to: 0.831, absoluteTolerance: 0.001))
        #expect(transformer(0.750).isApproximatelyEqual(to: 0.933, absoluteTolerance: 0.001))
        #expect(transformer(0.875).isApproximatelyEqual(to: 0.984, absoluteTolerance: 0.001))
        #expect(transformer(1.0) == 1.0)
    }

    @Test func pingPongTransformer() {
        let transformer = Transformer.pingPong.transform

        #expect(transformer(0.0) == 0.0)
        #expect(transformer(0.25) == 0.5)
        #expect(transformer(0.5) == 1.0)
        #expect(transformer(0.75) == 0.5)
        #expect(transformer(1.0) == 0.0)
    }

    @Test func reverseTransformer() {
        let transformer = Transformer.reverse.transform

        #expect(transformer(0.0) == 1.0)
        #expect(transformer(0.25) == 0.75)
        #expect(transformer(0.5) == 0.5)
        #expect(transformer(0.75) == 0.25)
        #expect(transformer(1.0) == 0.0)
    }

    @Test func connect() {
        let transformer = [Transformer.pingPong, Transformer.reverse].connected.transform

        #expect(transformer(0.0) == 1.0)
        #expect(transformer(0.25) == 0.5)
        #expect(transformer(0.5) == 0.0)
        #expect(transformer(0.75) == 0.5)
        #expect(transformer(1.0) == 1.0)
    }
}
