import Testing

@testable import BrassBand

@MainActor
struct LayoutValueGuideTests {
    @Test func initWithDefaultValue() {
        let guide = LayoutValueGuide()

        #expect(guide.value == 0.0)
    }

    @Test func initWithValue() {
        let guide = LayoutValueGuide(1.0)

        #expect(guide.value == 1.0)
    }

    @Test func observing() {
        let guide = LayoutValueGuide()

        var received: [Float] = []

        let canceller = guide.valuePublisher.sink {
            received.append($0)
        }

        #expect(received.count == 1)
        #expect(received[0] == 0.0)

        received.removeAll()

        guide.value = 1.0

        #expect(received.count == 1)
        #expect(received[0] == 1.0)

        received.removeAll()

        guide.suspendNotify {
            guide.value = 2.0

            #expect(received.count == 0)

            guide.suspendNotify {
                guide.value = 3.0

                #expect(received.count == 0)
            }

            guide.value = 4.0

            #expect(received.count == 0)
        }

        #expect(received.count == 1)
        #expect(received[0] == 4.0)

        received.removeAll()

        guide.value = 5.0

        #expect(received.count == 1)
        #expect(received[0] == 5.0)

        canceller.cancel()
    }

    @Test func suspendNotify() {
        let guide = LayoutValueGuide(1.0)

        var called = false

        let canceller = guide.valuePublisher.sink { _ in
            called = true
        }

        called = false

        guide.suspendNotify {
            guide.value = 2.0
            guide.value = 1.0
        }

        #expect(!called)

        canceller.cancel()
    }
}
