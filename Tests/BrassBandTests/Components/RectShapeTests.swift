import Testing

@testable import BrassBand

struct RectShapeTests {
    @Test func kind() {
        #expect(RectShape().kind == .rect)
    }

    @Test func initialRect() {
        #expect(RectShape().rect == .init(center: .zero, size: .one))
    }

    @Test func hitTestWithPoint() {
        let shape = RectShape()

        #expect(shape.hitTest(.init(x: -0.499, y: -0.499)))
        #expect(shape.hitTest(.init(x: 0.499, y: 0.499)))

        #expect(!shape.hitTest(.init(x: -0.501, y: -0.499)))
        #expect(!shape.hitTest(.init(x: -0.499, y: -0.501)))
        #expect(!shape.hitTest(.init(x: 0.501, y: 0.499)))
        #expect(!shape.hitTest(.init(x: 0.499, y: 0.501)))
    }

    @Test func hitTestWithRegion() {
        let shape = RectShape(rect: .init(center: .zero, size: .init(repeating: 2.0)))

        #expect(
            shape.hitTest(.init(center: .init(x: -1.999, y: -1.999), size: .init(repeating: 2.0))))
        #expect(
            shape.hitTest(.init(center: .init(x: 1.999, y: 1.999), size: .init(repeating: 2.0))))

        #expect(
            !shape.hitTest(.init(center: .init(x: -2.001, y: -1.999), size: .init(repeating: 2.0)))
        )
        #expect(
            !shape.hitTest(.init(center: .init(x: -1.999, y: -2.001), size: .init(repeating: 2.0)))
        )
        #expect(
            !shape.hitTest(.init(center: .init(x: 2.001, y: 1.999), size: .init(repeating: 2.0))))
        #expect(
            !shape.hitTest(.init(center: .init(x: 1.999, y: 2.001), size: .init(repeating: 2.0))))
    }
}
