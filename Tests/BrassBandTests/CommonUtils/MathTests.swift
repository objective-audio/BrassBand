import BrassBand
import Testing

struct MathTests {
    @Test func roundfWithScale() {
        #expect(round(Float(0.6), scale: 2.0) == 0.5)
        #expect(round(Float(0.4), scale: 2.0) == 0.5)
        #expect(round(Float(0.8), scale: 2.0) == 1.0)
        #expect(round(Float(0.2), scale: 2.0) == 0.0)
    }

    @Test func roundWithScale() {
        #expect(round(0.6, scale: 2.0) == 0.5)
        #expect(round(0.4, scale: 2.0) == 0.5)
        #expect(round(0.8, scale: 2.0) == 1.0)
        #expect(round(0.2, scale: 2.0) == 0.0)
    }

    @Test func ceilfWithScale() {
        #expect(ceil(Float(0.2), scale: 2.0) == 0.5)
        #expect(ceil(Float(0.4), scale: 2.0) == 0.5)
        #expect(ceil(Float(0.6), scale: 2.0) == 1.0)
        #expect(ceil(Float(0.8), scale: 2.0) == 1.0)
    }

    @Test func ceilWithScale() {
        #expect(ceil(0.2, scale: 2.0) == 0.5)
        #expect(ceil(0.4, scale: 2.0) == 0.5)
        #expect(ceil(0.6, scale: 2.0) == 1.0)
        #expect(ceil(0.8, scale: 2.0) == 1.0)
    }

    @Test func clampZeroToOne() {
        #expect(BrassBand.clampZeroToOne(0.0) == 0.0)
        #expect(BrassBand.clampZeroToOne(0.1) == 0.1)
        #expect(BrassBand.clampZeroToOne(0.5) == 0.5)
        #expect(BrassBand.clampZeroToOne(0.9) == 0.9)
        #expect(BrassBand.clampZeroToOne(1.0) == 1.0)

        #expect(BrassBand.clampZeroToOne(-0.001) == 0.0)
        #expect(BrassBand.clampZeroToOne(-1.0) == 0.0)
        #expect(BrassBand.clampZeroToOne(1.001) == 1.0)
        #expect(BrassBand.clampZeroToOne(2.0) == 1.0)
    }
}
