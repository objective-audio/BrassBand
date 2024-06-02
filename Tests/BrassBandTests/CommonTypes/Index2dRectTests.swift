import BrassBand
import Testing

struct Index2dRectTests {
    @Test func testIsEqual() {
        var rect1 = Index2dRect()
        rect1.setAll(first: 1)

        var rect1b = Index2dRect()
        rect1b.setAll(first: 1)

        var rect2 = Index2dRect()
        rect2.setAll(first: 2)

        #expect(rect1 == rect1b)
        #expect(rect1 != rect2)
    }
}
