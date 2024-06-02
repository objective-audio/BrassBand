import Combine
import Testing

@testable import BrassBand

@MainActor
struct LayoutRangeGuideTests {
    @Test func initWithDefaultValue() {
        let guide = LayoutRangeGuide()

        #expect(guide.min == 0.0)
        #expect(guide.max == 0.0)
        #expect(guide.length == 0.0)
    }

    @Test func initWithRange() {
        do {
            let guide = LayoutRangeGuide(.init(location: 1.0, length: 2.0))

            #expect(guide.min == 1.0)
            #expect(guide.max == 3.0)
            #expect(guide.length == 2.0)
        }

        do {
            let guide = LayoutRangeGuide(.init(location: 4.0, length: -6.0))

            #expect(guide.min == -2.0)
            #expect(guide.max == 4.0)
            #expect(guide.length == 6.0)
        }
    }

    @Test func range() {
        let guide = LayoutRangeGuide()

        #expect(guide.range == .init(location: 0.0, length: 0.0))

        guide.range = .init(location: 1.0, length: 2.0)

        #expect(guide.range == .init(location: 1.0, length: 2.0))
    }

    @Test func observing() {
        let guide = LayoutRangeGuide()

        var received: [Range] = []

        let canceller = guide.rangePublisher.sink { range in
            received.append(range)
        }

        #expect(received.count == 1)

        guide.range = .init(location: 1.0, length: 2.0)

        #expect(received.count == 2)
        #expect(received[1].location == 1.0)
        #expect(received[1].length == 2.0)

        guide.minGuide.value = 0.0

        #expect(received.count == 3)
        #expect(received[2].location == 0.0)
        #expect(received[2].length == 3.0)

        guide.maxGuide.value = 4.0

        #expect(received.count == 4)
        #expect(received[3].location == 0.0)
        #expect(received[3].length == 4.0)

        canceller.cancel()
    }

    @Test func suspendNotify() {
        let guide = LayoutRangeGuide()

        var receivedMins: [Float] = []
        var receivedMaxs: [Float] = []
        var receivedLengths: [Float] = []
        var receivedRanges: [Range] = []

        let clearReceived = {
            receivedMins.removeAll()
            receivedMaxs.removeAll()
            receivedLengths.removeAll()
            receivedRanges.removeAll()
        }

        var cancellers: Set<AnyCancellable> = []

        guide.minGuide.valuePublisher.sink {
            receivedMins.append($0)
        }.store(in: &cancellers)
        guide.maxGuide.valuePublisher.sink {
            receivedMaxs.append($0)
        }.store(in: &cancellers)
        guide.layoutLengthValueSource.layoutValuePublisher.sink {
            receivedLengths.append($0)
        }.store(in: &cancellers)
        guide.rangePublisher.sink {
            receivedRanges.append($0)
        }.store(in: &cancellers)

        clearReceived()

        guide.range = .init(location: 1.0, length: 2.0)

        #expect(receivedMins.count == 1)
        #expect(receivedMins[0] == 1.0)
        #expect(receivedMaxs.count == 1)
        #expect(receivedMaxs[0] == 3.0)
        #expect(receivedLengths.count == 1)
        #expect(receivedLengths[0] == 2.0)
        #expect(receivedRanges.count == 1)
        #expect(receivedRanges[0].location == 1.0)
        #expect(receivedRanges[0].length == 2.0)

        clearReceived()

        guide.suspendNotify {
            guide.range = .init(location: 3.0, length: 4.0)

            #expect(receivedMins.count == 0)
            #expect(receivedMaxs.count == 0)
            #expect(receivedLengths.count == 0)
            #expect(receivedRanges.count == 0)

            guide.suspendNotify {
                guide.range = .init(location: 5.0, length: 6.0)

                #expect(receivedMins.count == 0)
                #expect(receivedMaxs.count == 0)
                #expect(receivedLengths.count == 0)
                #expect(receivedRanges.count == 0)
            }

            guide.range = .init(location: 7.0, length: 8.0)

            #expect(receivedMins.count == 0)
            #expect(receivedMaxs.count == 0)
            #expect(receivedLengths.count == 0)
            #expect(receivedRanges.count == 0)
        }

        #expect(receivedMins.count == 1)
        #expect(receivedMins[0] == 7.0)
        #expect(receivedMaxs.count == 1)
        #expect(receivedMaxs[0] == 15.0)
        #expect(receivedLengths.count == 1)
        #expect(receivedLengths[0] == 8.0)
        #expect(receivedRanges.count == 1)
        #expect(receivedRanges[0].location == 7.0)
        #expect(receivedRanges[0].length == 8.0)

        clearReceived()

        guide.range = .init(location: 9.0, length: 10.0)

        #expect(receivedMins.count == 1)
        #expect(receivedMins[0] == 9.0)
        #expect(receivedMaxs.count == 1)
        #expect(receivedMaxs[0] == 19.0)
        #expect(receivedLengths.count == 1)
        #expect(receivedLengths[0] == 10.0)
        #expect(receivedRanges.count == 1)
        #expect(receivedRanges[0].location == 9.0)
        #expect(receivedRanges[0].length == 10.0)
    }

    @Test(arguments: [
        (value: Float(-1.0), expected: Range(location: -1.0, length: 2.0)),
        (value: Float(0.0), expected: Range(location: 0.0, length: 1.0)),
        (value: Float(1.0), expected: Range(location: 1.0, length: 0.0)),
        (value: Float(2.0), expected: Range(location: 2.0, length: 0.0)),
    ])
    func setMinGuide(value: Float, expected: Range) {
        let guide = LayoutRangeGuide()
        guide.range = .init(location: 0.0, length: 1.0)
        guide.minGuide.value = value
        #expect(guide.min == expected.min)
        #expect(guide.max == expected.max)
        #expect(guide.length == expected.length)
    }

    @Test(arguments: [
        (value: Float(2.0), expected: Range(location: 0.0, length: 2.0)),
        (value: Float(1.0), expected: Range(location: 0.0, length: 1.0)),
        (value: Float(0.0), expected: Range(location: 0.0, length: 0.0)),
        (value: Float(-1.0), expected: Range(location: -1.0, length: 0.0)),
    ])
    func setMaxGuide(value: Float, expected: Range) {
        let guide = LayoutRangeGuide()
        guide.range = .init(location: 0.0, length: 1.0)
        guide.maxGuide.value = value
        #expect(guide.min == expected.min)
        #expect(guide.max == expected.max)
        #expect(guide.length == expected.length)
    }
}
