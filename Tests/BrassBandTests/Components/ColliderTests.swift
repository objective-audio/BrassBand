import Testing

@testable import BrassBand

@MainActor
struct ColliderTest {
    @Test func shape() {
        let collider = Collider()

        #expect(collider.shape == nil)

        collider.shape = RectShape(rect: .zero)

        #expect(collider.shape != nil)
        #expect(collider.shape?.kind == .rect)

        collider.shape = nil

        #expect(collider.shape == nil)
    }

    @Test func isEnabled() {
        let collider = Collider()

        #expect(collider.isEnabled)

        collider.isEnabled = false

        #expect(!collider.isEnabled)
    }

    @Test func hitTestNoShapeWithPoint() {
        let collider = Collider()

        #expect(!collider.hitTest(Point.zero))
    }

    @Test func hitTestNoShapeWithRegion() {
        let collider = Collider()

        #expect(!collider.hitTest(Region(origin: .zero, size: .one)))
    }

    @Test func hitTestAnywhereShapeWithPoint() {
        let collider = Collider(shape: AnywhereShape())

        #expect(!collider.hitTest(Point.zero))

        collider.matrix = matrix_identity_float4x4

        #expect(collider.hitTest(Point.zero))
        #expect(collider.hitTest(Point(x: .greatestFiniteMagnitude, y: .greatestFiniteMagnitude)))
        #expect(collider.hitTest(Point(x: .leastNormalMagnitude, y: .leastNormalMagnitude)))
    }

    @Test func hitTestAnywhereShareWithRegion() {
        let collider = Collider(shape: AnywhereShape())

        #expect(!collider.hitTest(Region.zero))

        collider.matrix = matrix_identity_float4x4

        #expect(collider.hitTest(Region.zero))
        #expect(collider.hitTest(Region(origin: .zero, size: .one)))
    }

    @Test func hitTestRectShapeWithPoint() {
        let collider = Collider(shape: RectShape(rect: .init(center: .zero, size: .one)))

        #expect(!collider.hitTest(Point.zero))

        collider.matrix = matrix_identity_float4x4

        #expect(collider.hitTest(Point.zero))
        #expect(collider.hitTest(Point(repeating: -0.49)))
        #expect(collider.hitTest(Point(repeating: 0.49)))

        #expect(!collider.hitTest(Point(x: -0.51, y: 0.0)))
        #expect(!collider.hitTest(Point(x: 0.51, y: 0.0)))
        #expect(!collider.hitTest(Point(x: 0.0, y: -0.51)))
        #expect(!collider.hitTest(Point(x: 0.0, y: 0.51)))
    }

    @Test func hitTestRectShapeWithRegion() {
        let collider = Collider(shape: RectShape(rect: .init(center: .zero, size: .one)))

        #expect(!collider.hitTest(Region.zero))

        collider.matrix = matrix_identity_float4x4

        #expect(collider.hitTest(Region.zero))
        #expect(collider.hitTest(Region(origin: .init(x: -0.49, y: 0.0), size: .zero)))
        #expect(collider.hitTest(Region(origin: .init(x: 0.49, y: 0.0), size: .zero)))
        #expect(collider.hitTest(Region(origin: .init(x: 0.0, y: -0.49), size: .zero)))
        #expect(collider.hitTest(Region(origin: .init(x: 0.0, y: 0.49), size: .zero)))

        #expect(!collider.hitTest(Region(origin: .init(x: -0.51, y: 0.0), size: .zero)))
        #expect(!collider.hitTest(Region(origin: .init(x: 0.51, y: 0.0), size: .zero)))
        #expect(!collider.hitTest(Region(origin: .init(x: 0.0, y: -0.51), size: .zero)))
        #expect(!collider.hitTest(Region(origin: .init(x: 0.0, y: 0.51), size: .zero)))
    }

    @Test func hitTestCircleShapeWithPoint() {
        let collider = Collider(shape: CircleShape(center: .init(repeating: 0.0), radius: 0.5))

        #expect(!collider.hitTest(Point.zero))

        collider.matrix = matrix_identity_float4x4

        #expect(collider.hitTest(Point.zero))
        #expect(collider.hitTest(Point(x: -0.49, y: 0.0)))
        #expect(collider.hitTest(Point(x: 0.49, y: 0.0)))
        #expect(collider.hitTest(Point(x: 0.0, y: -0.49)))
        #expect(collider.hitTest(Point(x: 0.0, y: 0.49)))

        #expect(collider.hitTest(Point(repeating: -0.35)))
        #expect(collider.hitTest(Point(repeating: 0.35)))

        #expect(!collider.hitTest(Point(x: -0.51, y: 0.0)))
        #expect(!collider.hitTest(Point(x: 0.51, y: 0.0)))
        #expect(!collider.hitTest(Point(x: 0.0, y: -0.51)))
        #expect(!collider.hitTest(Point(x: 0.0, y: 0.51)))

        #expect(!collider.hitTest(Point(repeating: -0.36)))
        #expect(!collider.hitTest(Point(repeating: 0.36)))
    }

    @Test func hitTestCircleShapeWithRegion() {
        let collider = Collider(shape: CircleShape(center: .init(repeating: 0.0), radius: 0.5))

        #expect(!collider.hitTest(Region.zero))

        collider.matrix = matrix_identity_float4x4

        #expect(collider.hitTest(Region.zero))

        #expect(collider.hitTest(Region(origin: .init(repeating: 0.35), size: .one)))
        #expect(collider.hitTest(Region(origin: .init(repeating: -1.35), size: .one)))
        #expect(collider.hitTest(Region(origin: .init(x: 0.35, y: -1.35), size: .one)))
        #expect(collider.hitTest(Region(origin: .init(x: -1.35, y: 0.35), size: .one)))

        #expect(!collider.hitTest(Region(origin: .init(repeating: 0.36), size: .one)))
        #expect(!collider.hitTest(Region(origin: .init(repeating: -1.36), size: .one)))
        #expect(!collider.hitTest(Region(origin: .init(x: 0.36, y: -1.36), size: .one)))
        #expect(!collider.hitTest(Region(origin: .init(x: -1.36, y: 0.36), size: .one)))
    }

    @Test func matrix() {
        let collider = Collider()

        #expect(collider.matrix == nil)

        collider.matrix = matrix_identity_float4x4

        #expect(collider.matrix == matrix_identity_float4x4)
    }

    @Test func hitTestWithEnabled() {
        let collider = Collider(shape: AnywhereShape())
        collider.matrix = matrix_identity_float4x4

        collider.isEnabled = true

        #expect(collider.hitTest(Point.zero))
        #expect(collider.hitTest(Region.zero))

        collider.isEnabled = false

        #expect(!collider.hitTest(Point.zero))
        #expect(!collider.hitTest(Region.zero))
    }

    @Test func kind() {
        let collider = Collider()

        collider.shape = CircleShape(center: .zero, radius: 0)
        #expect(collider.kind == .circle)

        collider.shape = AnywhereShape()
        #expect(collider.kind == .anywhere)

        collider.shape = RectShape(rect: .zero)
        #expect(collider.kind == .rect)
    }
}
