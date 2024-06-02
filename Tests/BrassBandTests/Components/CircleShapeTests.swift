import Testing

@testable import BrassBand

struct CircleShapeTests {
    @Test func kind() {
        #expect(CircleShape().kind == .circle)
    }

    @Test func initialProperties() {
        let shape = CircleShape()

        #expect(shape.center == .zero)
        #expect(shape.radius == 0.5)
    }

    @Test func hitTestWithPoint() {
        let shape = CircleShape()

        // 上下左右

        #expect(shape.hitTest(.init(x: -0.499, y: 0.0)))
        #expect(shape.hitTest(.init(x: 0.0, y: -0.499)))
        #expect(shape.hitTest(.init(x: 0.499, y: 0.0)))
        #expect(shape.hitTest(.init(x: 0.0, y: 0.499)))

        #expect(!shape.hitTest(.init(x: -0.501, y: 0.0)))
        #expect(!shape.hitTest(.init(x: 0.0, y: -0.501)))
        #expect(!shape.hitTest(.init(x: 0.501, y: 0.0)))
        #expect(!shape.hitTest(.init(x: 0.0, y: 0.501)))

        // 斜め

        #expect(shape.hitTest(.init(x: Float(-0.707 * 0.5), y: Float(-0.707 * 0.5))))
        #expect(shape.hitTest(.init(x: Float(0.707 * 0.5), y: Float(0.707 * 0.5))))
        #expect(!shape.hitTest(.init(x: Float(-0.708 * 0.5), y: Float(-0.708 * 0.5))))
        #expect(!shape.hitTest(.init(x: Float(0.708 * 0.5), y: Float(0.708 * 0.5))))
    }

    @Test func hitTestWithRegion() {
        let shape = CircleShape(center: .zero, radius: 1.0)

        // 上下左右

        #expect(
            shape.hitTest(Region(center: .init(x: -1.999, y: -1.0), size: .init(repeating: 2.0))))
        #expect(
            shape.hitTest(Region(center: .init(x: -1.0, y: -1.999), size: .init(repeating: 2.0))))
        #expect(shape.hitTest(Region(center: .init(x: 1.999, y: 1.0), size: .init(repeating: 2.0))))
        #expect(shape.hitTest(Region(center: .init(x: 1.0, y: 1.999), size: .init(repeating: 2.0))))

        #expect(
            !shape.hitTest(Region(center: .init(x: -2.001, y: -1.0), size: .init(repeating: 2.0))))
        #expect(
            !shape.hitTest(Region(center: .init(x: -1.0, y: -2.001), size: .init(repeating: 2.0))))
        #expect(
            !shape.hitTest(Region(center: .init(x: 2.001, y: 1.0), size: .init(repeating: 2.0))))
        #expect(
            !shape.hitTest(Region(center: .init(x: 1.0, y: 2.001), size: .init(repeating: 2.0))))

        // 斜め

        #expect(
            shape.hitTest(
                .init(
                    center: .init(x: Float(-0.707 - 1.0), y: Float(-0.707 - 1.0)),
                    size: .init(repeating: 2.0))))
        #expect(
            shape.hitTest(
                .init(
                    center: .init(x: Float(0.707 + 1.0), y: Float(0.707 + 1.0)),
                    size: .init(repeating: 2.0))))
        #expect(
            !shape.hitTest(
                .init(
                    center: .init(x: Float(-0.708 - 1.0), y: Float(-0.708 - 1.0)),
                    size: .init(repeating: 2.0))))
        #expect(
            !shape.hitTest(
                .init(
                    center: .init(x: Float(0.708 + 1.0), y: Float(0.708 + 1.0)),
                    size: .init(repeating: 2.0))))
    }
}
