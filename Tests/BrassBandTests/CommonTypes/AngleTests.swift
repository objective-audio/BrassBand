import BrassBand
import Numerics
import Testing

struct AngleTests {
    @Test func initWithDegrees() {
        let angle = Angle(degrees: 180.0)

        #expect(angle.radians.isApproximatelyEqual(to: Float.pi, absoluteTolerance: 0.001))
        #expect(angle.degrees.isApproximatelyEqual(to: 180.0, absoluteTolerance: 0.001))
    }

    @Test func initWithRadians() {
        let angle = Angle(radians: .pi)

        #expect(angle.radians.isApproximatelyEqual(to: Float.pi, absoluteTolerance: 0.001))
        #expect(angle.degrees.isApproximatelyEqual(to: 180.0, absoluteTolerance: 0.001))
    }

    @Test func equal() {
        let angle1A = Angle(degrees: 1.0)
        let angle1B = Angle(degrees: 1.0)
        let angle2 = Angle(degrees: 2.0)

        #expect(angle1A == angle1B)
        #expect(angle1A != angle2)
    }

    @Test func plus() {
        let angleA = Angle(degrees: 1.0)
        let angleB = Angle(degrees: 2.0)
        let angleC = angleA + angleB

        #expect(angleC.degrees.isApproximatelyEqual(to: 3.0, absoluteTolerance: 0.001))
    }

    @Test func minus() {
        let angleA = Angle(degrees: 3.0)
        let angleB = Angle(degrees: 1.0)
        let angleC = angleA - angleB

        #expect(angleC.degrees.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
    }

    @Test func multi() {
        let angle = Angle(degrees: 2.0) * 3.0

        #expect(angle.degrees.isApproximatelyEqual(to: 6.0, absoluteTolerance: 0.001))
    }

    @Test func divide() {
        let angle = Angle(degrees: 6.0) / 3.0

        #expect(angle.degrees.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
    }

    @Test func plusEqual() {
        var angle = Angle(degrees: 1.0)
        angle += Angle(degrees: 2.0)

        #expect(angle.degrees.isApproximatelyEqual(to: 3.0, absoluteTolerance: 0.001))
    }

    @Test func minusEqual() {
        var angle = Angle(degrees: 3.0)
        angle -= Angle(degrees: 1.0)

        #expect(angle.degrees.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
    }

    @Test func multiEqual() {
        var angle = Angle(degrees: 2.0)
        angle *= 3.0

        #expect(angle.degrees.isApproximatelyEqual(to: 6.0, absoluteTolerance: 0.001))
    }

    @Test func divideEqual() {
        var angle = Angle(degrees: 6.0)
        angle /= 3.0

        #expect(angle.degrees.isApproximatelyEqual(to: 2.0, absoluteTolerance: 0.001))
    }

    @Test func unaryMinus() {
        let angle = Angle(degrees: 1.0)

        #expect((-angle).degrees.isApproximatelyEqual(to: -1.0, absoluteTolerance: 0.001))
    }

    @Test func shortestFrom() {
        #expect(
            Angle(degrees: 360.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 450.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 540.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 630.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: -90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 720.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))

        #expect(
            Angle(degrees: 179.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 180.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 181.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: -179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 269.0).shortest(from: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: 269.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 270.0).shortest(from: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: 270.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 271.0).shortest(from: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: -89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 89.0).shortest(from: .init(degrees: -90.0)).degrees.isApproximatelyEqual(
                to: 89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(from: .init(degrees: -90.0)).degrees.isApproximatelyEqual(
                to: 90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 91.0).shortest(from: .init(degrees: -90.0)).degrees.isApproximatelyEqual(
                to: -269.0, absoluteTolerance: 0.001))

        #expect(
            Angle(degrees: -360.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -450.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: -90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -540.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: -180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -630.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -720.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))

        #expect(
            Angle(degrees: -179.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: -179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -180.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: -180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -181.0).shortest(from: .init(degrees: 0.0)).degrees.isApproximatelyEqual(
                to: 179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -269.0).shortest(from: .init(degrees: -90.0)).degrees
                .isApproximatelyEqual(to: -269.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -270.0).shortest(from: .init(degrees: -90.0)).degrees
                .isApproximatelyEqual(to: -270.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -271.0).shortest(from: .init(degrees: -90.0)).degrees
                .isApproximatelyEqual(to: 89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -89.0).shortest(from: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: -89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(from: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: -90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -91.0).shortest(from: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: 269.0, absoluteTolerance: 0.001))

        #expect(Angle(degrees: 1.0).shortest(from: .init(degrees: 1.0)) == .zero)
    }

    @Test func shortestTo() {
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 360.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 450.0)).degrees.isApproximatelyEqual(
                to: 90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 540.0)).degrees.isApproximatelyEqual(
                to: 180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 630.0)).degrees.isApproximatelyEqual(
                to: -90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 720.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))

        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 179.0)).degrees.isApproximatelyEqual(
                to: 179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 180.0)).degrees.isApproximatelyEqual(
                to: 180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: 181.0)).degrees.isApproximatelyEqual(
                to: -179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(to: .init(degrees: 269.0)).degrees.isApproximatelyEqual(
                to: 269.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(to: .init(degrees: 270.0)).degrees.isApproximatelyEqual(
                to: 270.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(to: .init(degrees: 271.0)).degrees.isApproximatelyEqual(
                to: -89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(to: .init(degrees: 89.0)).degrees.isApproximatelyEqual(
                to: 89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(to: .init(degrees: 90.0)).degrees.isApproximatelyEqual(
                to: 90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(to: .init(degrees: 91.0)).degrees.isApproximatelyEqual(
                to: -269.0, absoluteTolerance: 0.001))

        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -360.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -450.0)).degrees.isApproximatelyEqual(
                to: -90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -540.0)).degrees.isApproximatelyEqual(
                to: -180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -630.0)).degrees.isApproximatelyEqual(
                to: 90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -720.0)).degrees.isApproximatelyEqual(
                to: 0.0, absoluteTolerance: 0.001))

        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -179.0)).degrees.isApproximatelyEqual(
                to: -179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -180.0)).degrees.isApproximatelyEqual(
                to: -180.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 0.0).shortest(to: .init(degrees: -181.0)).degrees.isApproximatelyEqual(
                to: 179.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(to: .init(degrees: -269.0)).degrees.isApproximatelyEqual(
                to: -269.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(to: .init(degrees: -270.0)).degrees.isApproximatelyEqual(
                to: -270.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: -90.0).shortest(to: .init(degrees: -271.0)).degrees.isApproximatelyEqual(
                to: 89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(to: .init(degrees: -89.0)).degrees.isApproximatelyEqual(
                to: -89.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(to: .init(degrees: -90.0)).degrees.isApproximatelyEqual(
                to: -90.0, absoluteTolerance: 0.001))
        #expect(
            Angle(degrees: 90.0).shortest(to: .init(degrees: -91.0)).degrees.isApproximatelyEqual(
                to: 269.0, absoluteTolerance: 0.001))
    }

    @Test func zero() {
        #expect(Angle.zero.degrees == 0.0)
        #expect(Angle.zero.radians == 0.0)
    }
}
