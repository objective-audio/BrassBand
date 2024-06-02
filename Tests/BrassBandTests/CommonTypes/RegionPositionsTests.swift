import BrassBand
import Testing

struct RegionPositionsTests {
    @Test func initWithRegion() {
        let region = Region(origin: .init(x: 0.0, y: 2.0), size: .init(width: 4.0, height: 8.0))
        let positions = RegionPositions(region)

        #expect(positions[0].x == region.left)
        #expect(positions[0].y == region.bottom)
        #expect(positions[1].x == region.right)
        #expect(positions[1].y == region.bottom)
        #expect(positions[2].x == region.left)
        #expect(positions[2].y == region.top)
        #expect(positions[3].x == region.right)
        #expect(positions[3].y == region.top)
    }

    @Test func initWithUIntRegion() {
        let region = UIntRegion(origin: .init(x: 0, y: 2), size: .init(width: 4, height: 8))
        let positions = RegionPositions(region)

        #expect(positions[0].x == Float(region.left))
        #expect(positions[0].y == Float(region.top))
        #expect(positions[1].x == Float(region.right))
        #expect(positions[1].y == Float(region.top))
        #expect(positions[2].x == Float(region.left))
        #expect(positions[2].y == Float(region.bottom))
        #expect(positions[3].x == Float(region.right))
        #expect(positions[3].y == Float(region.bottom))
    }

    @Test func applied() {
        let positions = Region(origin: .init(x: 0.0, y: 2.0), size: .init(width: 4.0, height: 8.0))
            .positions
        let matrix = simd_float4x4.translation(x: 1.0, y: 2.0)
        let appliedPositions = positions.applied(matrix: matrix)

        let expectedLeft: Float = 0.0 + 1.0
        let expectedBottom: Float = 2.0 + 2.0
        let expectedRight: Float = 0.0 + 4.0 + 1.0
        let expectedTop: Float = 2.0 + 2.0 + 8.0

        #expect(appliedPositions[0].x == expectedLeft)
        #expect(appliedPositions[0].y == expectedBottom)
        #expect(appliedPositions[1].x == expectedRight)
        #expect(appliedPositions[1].y == expectedBottom)
        #expect(appliedPositions[2].x == expectedLeft)
        #expect(appliedPositions[2].y == expectedTop)
        #expect(appliedPositions[3].x == expectedRight)
        #expect(appliedPositions[3].y == expectedTop)
    }

    @Test func corners() {
        let regionPositions = RegionPositions(
            .init(origin: .init(x: 0.0, y: 2.0), size: .init(width: 4.0, height: 8.0)))

        #expect(regionPositions.leftBottom == SIMD2<Float>(x: 0.0, y: 2.0))
        #expect(regionPositions.rightBottom == SIMD2<Float>(x: 4.0, y: 2.0))
        #expect(regionPositions.leftTop == SIMD2<Float>(x: 0.0, y: 10.0))
        #expect(regionPositions.rightTop == SIMD2<Float>(x: 4.0, y: 10.0))
    }
}
