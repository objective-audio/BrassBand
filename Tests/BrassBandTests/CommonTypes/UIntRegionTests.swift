import BrassBand
import Testing

struct UIntRegionTests {
    @Test func isEqual() {
        let originA1 = UIntPoint(x: 1, y: 2)
        let originA2 = UIntPoint(x: 1, y: 2)
        let originB = UIntPoint(x: 3, y: 4)

        let sizeA1 = UIntSize(width: 5, height: 6)
        let sizeA2 = UIntSize(width: 5, height: 6)
        let sizeB = UIntSize(width: 7, height: 8)

        let regionA1A1 = UIntRegion(origin: originA1, size: sizeA1)
        let regionA1A2 = UIntRegion(origin: originA1, size: sizeA2)
        let regionA2A1 = UIntRegion(origin: originA2, size: sizeA1)
        let regionA2A2 = UIntRegion(origin: originA2, size: sizeA2)
        let regionB = UIntRegion(origin: originB, size: sizeB)

        #expect(regionA1A1 == regionA1A1)
        #expect(regionA1A1 == regionA1A2)
        #expect(regionA1A1 == regionA2A1)
        #expect(regionA1A1 == regionA2A2)
        #expect(regionA1A1 != regionB)
    }

    @Test func edgeProperties() {
        let region = UIntRegion(origin: .init(x: 0, y: 1), size: .init(width: 2, height: 3))

        #expect(region.left == 0)
        #expect(region.right == 2)
        #expect(region.bottom == 1)
        #expect(region.top == 4)
    }

    @Test func zero() {
        #expect(UIntRegion.zero.origin.x == 0)
        #expect(UIntRegion.zero.origin.y == 0)
        #expect(UIntRegion.zero.size.width == 0)
        #expect(UIntRegion.zero.size.height == 0)
    }

    @Test func positions() {
        let region = UIntRegion(origin: .init(x: 0, y: 2), size: .init(width: 4, height: 8))
        let positions = region.positions

        #expect(positions[0].x == Float(region.left))
        #expect(positions[0].y == Float(region.top))
        #expect(positions[1].x == Float(region.right))
        #expect(positions[1].y == Float(region.top))
        #expect(positions[2].x == Float(region.left))
        #expect(positions[2].y == Float(region.bottom))
        #expect(positions[3].x == Float(region.right))
        #expect(positions[3].y == Float(region.bottom))
    }
}
