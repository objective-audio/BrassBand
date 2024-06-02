import Testing

@testable import BrassBand

@MainActor
struct LayoutLinkTests {
    @Test func valueLink() {
        let source = LayoutValueGuide()
        let destination = LayoutValueGuide()

        let link = LayoutValueLink(source: source, destination: destination)

        #expect(source === link.source)
        #expect(destination === link.destination)

        let valueLinks = link.layoutValueLinks

        #expect(valueLinks.count == 1)
        #expect(valueLinks[0].source === source)
        #expect(valueLinks[0].destination === destination)
    }

    @Test func pointLink() {
        let source = LayoutPointGuide()
        let destination = LayoutPointGuide()

        let link = LayoutPointLink(source: source, destination: destination)

        #expect(source === link.source)
        #expect(destination === link.destination)

        let valueLinks = link.layoutValueLinks

        #expect(valueLinks.count == 2)
        #expect(valueLinks[0].source === source.xGuide)
        #expect(valueLinks[0].destination === destination.xGuide)
        #expect(valueLinks[1].source === source.yGuide)
        #expect(valueLinks[1].destination === destination.yGuide)
    }

    @Test func rangeLink() {
        let source = LayoutRangeGuide()
        let destination = LayoutRangeGuide()

        let link = LayoutRangeLink(source: source, destination: destination)

        #expect(source === link.source)
        #expect(destination === link.destination)

        let valueLinks = link.layoutValueLinks

        #expect(valueLinks.count == 2)
        #expect(valueLinks[0].source === source.minGuide)
        #expect(valueLinks[0].destination === destination.minGuide)
        #expect(valueLinks[1].source === source.maxGuide)
        #expect(valueLinks[1].destination === destination.maxGuide)
    }

    @Test func regionLink() {
        let source = LayoutRegionGuide()
        let destination = LayoutRegionGuide()

        let link = LayoutRegionLink(source: source, destination: destination)

        #expect(source === link.source)
        #expect(destination === link.destination)

        let valueLinks = link.layoutValueLinks

        #expect(valueLinks.count == 4)
        #expect(valueLinks[0].source === source.leftGuide)
        #expect(valueLinks[0].destination === destination.leftGuide)
        #expect(valueLinks[1].source === source.rightGuide)
        #expect(valueLinks[1].destination === destination.rightGuide)
        #expect(valueLinks[2].source === source.bottomGuide)
        #expect(valueLinks[2].destination === destination.bottomGuide)
        #expect(valueLinks[3].source === source.topGuide)
        #expect(valueLinks[3].destination === destination.topGuide)
    }
}
