import Testing

@testable import BrassBand

@MainActor
struct LayoutPointGuideTests {
    @Test func initWithDefaultValue() {
        let guide = LayoutPointGuide()

        #expect(guide.xGuide.value == 0.0)
        #expect(guide.yGuide.value == 0.0)
    }

    @Test func initWithPoint() {
        let guide = LayoutPointGuide(.init(x: 1.0, y: 2.0))

        #expect(guide.xGuide.value == 1.0)
        #expect(guide.yGuide.value == 2.0)
    }

    @Test func point() {
        let guide = LayoutPointGuide()

        #expect(guide.point == .zero)

        guide.point = .init(x: 1.0, y: -1.0)

        #expect(guide.point == .init(x: 1.0, y: -1.0))
    }

    @Test func observing() {
        let guide = LayoutPointGuide()

        var received: [Point] = []

        let canceller = guide.layoutPointPublisher.sink { point in
            received.append(point)
        }

        #expect(received.count == 1)

        guide.point = .init(x: 1.0, y: 2.0)

        #expect(received.count == 2)
        #expect(received[1].x == 1.0)
        #expect(received[1].y == 2.0)

        guide.xGuide.value = 3.0

        #expect(received.count == 3)
        #expect(received[2].x == 3.0)
        #expect(received[2].y == 2.0)

        guide.yGuide.value = 4.0

        #expect(received.count == 4)
        #expect(received[3].x == 3.0)
        #expect(received[3].y == 4.0)

        canceller.cancel()
    }

    @Test func suspendNotify() {
        let guide = LayoutPointGuide()

        var receivedXs: [Float] = []
        var receivedYs: [Float] = []
        var receivedPoints: [Point] = []

        let clearReceived = {
            receivedXs.removeAll()
            receivedYs.removeAll()
            receivedPoints.removeAll()
        }

        let xCanceller = guide.xGuide.valuePublisher.sink { value in
            receivedXs.append(value)
        }
        let yCanceller = guide.yGuide.valuePublisher.sink { value in
            receivedYs.append(value)
        }
        let pointCanceller = guide.pointPublisher.sink { point in
            receivedPoints.append(point)
        }

        #expect(receivedXs.count == 1)
        #expect(receivedYs.count == 1)
        #expect(receivedPoints.count == 1)

        clearReceived()

        guide.point = .init(x: 1.0, y: 2.0)

        #expect(receivedXs.count == 1)
        #expect(receivedXs[0] == 1.0)
        #expect(receivedYs.count == 1)
        #expect(receivedYs[0] == 2.0)
        #expect(receivedPoints.count == 1)
        #expect(receivedPoints[0].x == 1.0)
        #expect(receivedPoints[0].y == 2.0)

        clearReceived()

        guide.suspendNotify {
            guide.point = .init(x: 3.0, y: 4.0)

            #expect(receivedXs.count == 0)
            #expect(receivedYs.count == 0)
            #expect(receivedPoints.count == 0)

            guide.suspendNotify {
                guide.point = .init(x: 5.0, y: 6.0)

                #expect(receivedXs.count == 0)
                #expect(receivedYs.count == 0)
                #expect(receivedPoints.count == 0)
            }

            guide.point = .init(x: 7.0, y: 8.0)

            #expect(receivedXs.count == 0)
            #expect(receivedYs.count == 0)
            #expect(receivedPoints.count == 0)
        }

        #expect(receivedXs.count == 1)
        #expect(receivedXs[0] == 7.0)
        #expect(receivedYs.count == 1)
        #expect(receivedYs[0] == 8.0)
        #expect(receivedPoints.count == 1)
        #expect(receivedPoints[0].x == 7.0)
        #expect(receivedPoints[0].y == 8.0)

        clearReceived()

        guide.point = .init(x: 9.0, y: 10.0)

        #expect(receivedXs.count == 1)
        #expect(receivedXs[0] == 9.0)
        #expect(receivedYs.count == 1)
        #expect(receivedYs[0] == 10.0)
        #expect(receivedPoints.count == 1)
        #expect(receivedPoints[0].x == 9.0)
        #expect(receivedPoints[0].y == 10.0)

        xCanceller.cancel()
        yCanceller.cancel()
        pointCanceller.cancel()
    }
}
