import Testing

@testable import BrassBand

@MainActor
struct LayoutRegionGuideTests {
    @Test func initWithDefaultValue() {
        let guide = LayoutRegionGuide()

        #expect(guide.verticalRange.minGuide.value == 0.0)
        #expect(guide.verticalRange.maxGuide.value == 0.0)
        #expect(guide.horizontalRange.minGuide.value == 0.0)
        #expect(guide.horizontalRange.maxGuide.value == 0.0)
        #expect(guide.leftGuide.value == 0.0)
        #expect(guide.rightGuide.value == 0.0)
        #expect(guide.bottomGuide.value == 0.0)
        #expect(guide.topGuide.value == 0.0)
        #expect(guide.widthSource.layoutValue == 0.0)
        #expect(guide.heightSource.layoutValue == 0.0)
    }

    @Test func initWithRegion() {
        let guide = LayoutRegionGuide(
            .init(
                horizontalRange: .init(location: 13.0, length: 2.0),
                verticalRange: .init(location: 11.0, length: 1.0)))

        #expect(guide.verticalRange.minGuide.value == 11.0)
        #expect(guide.verticalRange.maxGuide.value == 12.0)
        #expect(guide.horizontalRange.minGuide.value == 13.0)
        #expect(guide.horizontalRange.maxGuide.value == 15.0)
        #expect(guide.bottomGuide.value == 11.0)
        #expect(guide.topGuide.value == 12.0)
        #expect(guide.leftGuide.value == 13.0)
        #expect(guide.rightGuide.value == 15.0)
        #expect(guide.widthSource.layoutValue == 2.0)
        #expect(guide.heightSource.layoutValue == 1.0)
    }

    @Test func setVerticalRange() {
        let guide = LayoutRegionGuide()

        guide.verticalRange.range = .init(location: 100.0, length: 101.0)

        #expect(guide.bottomGuide.value == 100.0)
        #expect(guide.topGuide.value == 201.0)
        #expect(guide.leftGuide.value == 0.0)
        #expect(guide.rightGuide.value == 0.0)
        #expect(guide.widthSource.layoutValue == 0.0)
        #expect(guide.heightSource.layoutValue == 101.0)
    }

    @Test func setHorizontalRange() {
        let guide = LayoutRegionGuide()

        guide.horizontalRange.range = .init(location: 300.0, length: 102.0)

        #expect(guide.bottomGuide.value == 0.0)
        #expect(guide.topGuide.value == 0.0)
        #expect(guide.leftGuide.value == 300.0)
        #expect(guide.rightGuide.value == 402.0)
        #expect(guide.widthSource.layoutValue == 102.0)
        #expect(guide.heightSource.layoutValue == 0.0)
    }

    @Test func setRanges() {
        let guide = LayoutRegionGuide()

        guide.setRanges(
            .init(
                vertical: .init(location: 11.0, length: 1.0),
                horizontal: .init(location: 13.0, length: 2.0)))

        #expect(guide.bottomGuide.value == 11.0)
        #expect(guide.topGuide.value == 12.0)
        #expect(guide.leftGuide.value == 13.0)
        #expect(guide.rightGuide.value == 15.0)
        #expect(guide.widthSource.layoutValue == 2.0)
        #expect(guide.heightSource.layoutValue == 1.0)
    }

    @Test func setRegion() {
        let guide = LayoutRegionGuide()

        guide.region = .init(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(guide.bottomGuide.value == 2.0)
        #expect(guide.topGuide.value == 6.0)
        #expect(guide.leftGuide.value == 1.0)
        #expect(guide.rightGuide.value == 4.0)
        #expect(guide.widthSource.layoutValue == 3.0)
        #expect(guide.heightSource.layoutValue == 4.0)
    }

    @Test func observing() {
        let guide = LayoutRegionGuide()

        var notified: [Region] = []

        let canceller = guide.regionPublisher.sink {
            notified.append($0)
        }

        notified.removeAll()

        guide.region = .init(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(notified.count == 1)
        #expect(notified[0].origin.x == 1.0)
        #expect(notified[0].origin.y == 2.0)
        #expect(notified[0].size.width == 3.0)
        #expect(notified[0].size.height == 4.0)

        guide.leftGuide.value = 0.0

        #expect(notified.count == 2)
        #expect(notified[1].origin.x == 0.0)
        #expect(notified[1].origin.y == 2.0)
        #expect(notified[1].size.width == 4.0)
        #expect(notified[1].size.height == 4.0)

        guide.verticalRange.range = .init(location: 8.0, length: 16.0)

        #expect(notified.count == 3)
        #expect(notified[2].origin.x == 0.0)
        #expect(notified[2].origin.y == 8.0)
        #expect(notified[2].size.width == 4.0)
        #expect(notified[2].size.height == 16.0)

        canceller.cancel()
    }

    @Test func suspendNotify() {
        let guide = LayoutRegionGuide()

        var notifiedLefts: [Float] = []
        var notifiedRights: [Float] = []
        var notifiedBottoms: [Float] = []
        var notifiedTops: [Float] = []
        var notifiedWidths: [Float] = []
        var notifiedHeights: [Float] = []
        var notifiedRegions: [Region] = []

        let clearNotified = {
            notifiedLefts.removeAll()
            notifiedRights.removeAll()
            notifiedBottoms.removeAll()
            notifiedTops.removeAll()
            notifiedWidths.removeAll()
            notifiedHeights.removeAll()
            notifiedRegions.removeAll()
        }

        var cancellers: Set<AnyCancellable> = []

        guide.leftGuide.valuePublisher.sink {
            notifiedLefts.append($0)
        }.store(in: &cancellers)
        guide.rightGuide.valuePublisher.sink {
            notifiedRights.append($0)
        }.store(in: &cancellers)
        guide.bottomGuide.valuePublisher.sink {
            notifiedBottoms.append($0)
        }.store(in: &cancellers)
        guide.topGuide.valuePublisher.sink {
            notifiedTops.append($0)
        }.store(in: &cancellers)
        guide.widthSource.layoutValuePublisher.sink {
            notifiedWidths.append($0)
        }.store(in: &cancellers)
        guide.heightSource.layoutValuePublisher.sink {
            notifiedHeights.append($0)
        }.store(in: &cancellers)
        guide.regionPublisher.sink {
            notifiedRegions.append($0)
        }.store(in: &cancellers)

        clearNotified()

        guide.region = .init(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(notifiedLefts.count == 1)
        #expect(notifiedLefts[0] == 1.0)
        #expect(notifiedRights.count == 1)
        #expect(notifiedRights[0] == 4.0)
        #expect(notifiedBottoms.count == 1)
        #expect(notifiedBottoms[0] == 2.0)
        #expect(notifiedTops.count == 1)
        #expect(notifiedTops[0] == 6.0)
        #expect(notifiedWidths.count == 1)
        #expect(notifiedWidths[0] == 3.0)
        #expect(notifiedHeights.count == 1)
        #expect(notifiedHeights[0] == 4.0)
        #expect(notifiedRegions.count == 1)
        #expect(notifiedRegions[0].origin.x == 1.0)
        #expect(notifiedRegions[0].origin.y == 2.0)
        #expect(notifiedRegions[0].size.width == 3.0)
        #expect(notifiedRegions[0].size.height == 4.0)

        clearNotified()

        guide.suspendNotify {
            guide.region = .init(
                origin: .init(x: 5.0, y: 6.0), size: .init(width: 7.0, height: 8.0))

            #expect(notifiedLefts.count == 0)
            #expect(notifiedRights.count == 0)
            #expect(notifiedBottoms.count == 0)
            #expect(notifiedTops.count == 0)
            #expect(notifiedWidths.count == 0)
            #expect(notifiedHeights.count == 0)
            #expect(notifiedRegions.count == 0)

            guide.suspendNotify {
                guide.region = .init(
                    origin: .init(x: 9.0, y: 10.0), size: .init(width: 11.0, height: 12.0))

                #expect(notifiedLefts.count == 0)
                #expect(notifiedRights.count == 0)
                #expect(notifiedBottoms.count == 0)
                #expect(notifiedTops.count == 0)
                #expect(notifiedWidths.count == 0)
                #expect(notifiedHeights.count == 0)
                #expect(notifiedRegions.count == 0)
            }

            guide.region = .init(
                origin: .init(x: 13.0, y: 14.0), size: .init(width: 15.0, height: 16.0))

            #expect(notifiedLefts.count == 0)
            #expect(notifiedRights.count == 0)
            #expect(notifiedBottoms.count == 0)
            #expect(notifiedTops.count == 0)
            #expect(notifiedWidths.count == 0)
            #expect(notifiedHeights.count == 0)
            #expect(notifiedRegions.count == 0)
        }

        #expect(notifiedLefts.count == 1)
        #expect(notifiedLefts[0] == 13.0)
        #expect(notifiedRights.count == 1)
        #expect(notifiedRights[0] == 28.0)
        #expect(notifiedBottoms.count == 1)
        #expect(notifiedBottoms[0] == 14.0)
        #expect(notifiedTops.count == 1)
        #expect(notifiedTops[0] == 30.0)
        #expect(notifiedWidths.count == 1)
        #expect(notifiedWidths[0] == 15.0)
        #expect(notifiedHeights.count == 1)
        #expect(notifiedHeights[0] == 16.0)
        #expect(notifiedRegions.count == 1)
        #expect(notifiedRegions[0].origin.x == 13.0)
        #expect(notifiedRegions[0].origin.y == 14.0)
        #expect(notifiedRegions[0].size.width == 15.0)
        #expect(notifiedRegions[0].size.height == 16.0)

        clearNotified()

        guide.region = .init(
            origin: .init(x: 17.0, y: 18.0), size: .init(width: 19.0, height: 20.0))

        #expect(notifiedLefts.count == 1)
        #expect(notifiedLefts[0] == 17.0)
        #expect(notifiedRights.count == 1)
        #expect(notifiedRights[0] == 36.0)
        #expect(notifiedBottoms.count == 1)
        #expect(notifiedBottoms[0] == 18.0)
        #expect(notifiedTops.count == 1)
        #expect(notifiedTops[0] == 38.0)
        #expect(notifiedWidths.count == 1)
        #expect(notifiedWidths[0] == 19.0)
        #expect(notifiedHeights.count == 1)
        #expect(notifiedHeights[0] == 20.0)
        #expect(notifiedRegions.count == 1)
        #expect(notifiedRegions[0].origin.x == 17.0)
        #expect(notifiedRegions[0].origin.y == 18.0)
        #expect(notifiedRegions[0].size.width == 19.0)
        #expect(notifiedRegions[0].size.height == 20.0)

        cancellers.forEach { $0.cancel() }
    }

    @Test func setByGuide() {
        let guide = LayoutRegionGuide()

        // horizontal

        guide.rightGuide.value = 1.0

        #expect(guide.leftGuide.value == 0.0)
        #expect(guide.rightGuide.value == 1.0)
        #expect(guide.widthSource.layoutValue == 1.0)

        guide.leftGuide.value = -1.0

        #expect(guide.leftGuide.value == -1.0)
        #expect(guide.rightGuide.value == 1.0)
        #expect(guide.widthSource.layoutValue == 2.0)

        // vertical

        guide.topGuide.value = 1.0

        #expect(guide.bottomGuide.value == 0.0)
        #expect(guide.topGuide.value == 1.0)
        #expect(guide.heightSource.layoutValue == 1.0)

        guide.bottomGuide.value = -1.0

        #expect(guide.bottomGuide.value == -1.0)
        #expect(guide.topGuide.value == 1.0)
        #expect(guide.heightSource.layoutValue == 2.0)
    }
}
