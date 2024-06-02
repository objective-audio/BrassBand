import Testing

@testable import BrassBand

struct AnywhereShapeTests {
    @Test func kind() {
        #expect(AnywhereShape().kind == .anywhere)
    }

    @Test func hitTestWithPoint() {
        #expect(AnywhereShape().hitTest(Point.zero))
    }

    @Test func hitTestWithRegion() {
        #expect(AnywhereShape().hitTest(Region.zero))
    }
}
