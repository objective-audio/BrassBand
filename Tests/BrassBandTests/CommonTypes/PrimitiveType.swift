import Testing

@testable import BrassBand

struct PrimitiveTypeTest {
    @Test func mtl() async throws {
        #expect(PrimitiveType.point.mtl == .point)
        #expect(PrimitiveType.line.mtl == .line)
        #expect(PrimitiveType.lineStrip.mtl == .lineStrip)
        #expect(PrimitiveType.triangle.mtl == .triangle)
        #expect(PrimitiveType.triangleStrip.mtl == .triangleStrip)
    }
}
