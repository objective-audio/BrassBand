import Testing

@testable import BrassBand

struct ScrollEventTests {
    @Test func phase() {
        let event = ScrollEvent(phase: .began, deltaX: 0.0, deltaY: 0.0, timestamp: 0.0)

        let phaseReplaced = event.phase(.ended)
        #expect(phaseReplaced.phase == .ended)
        #expect(phaseReplaced.deltaX == 0.0)
        #expect(phaseReplaced.deltaY == 0.0)
        #expect(phaseReplaced.timestamp == 0.0)
    }

    @Test func isEqual() {
        let event = ScrollEvent(phase: .began, deltaX: 0.0, deltaY: 0.0, timestamp: 0.0)

        // deltaが同じならtrue
        #expect(
            event.isEqual(
                toEvent: ScrollEvent(phase: .began, deltaX: 0.0, deltaY: 0.0, timestamp: 0.0)))
        #expect(
            event.isEqual(
                toEvent: ScrollEvent(phase: .ended, deltaX: 0.0, deltaY: 0.0, timestamp: 0.0)))
        #expect(
            event.isEqual(
                toEvent: ScrollEvent(phase: .began, deltaX: 0.0, deltaY: 0.0, timestamp: 1.0)))

        // deltaが違うならfalse
        #expect(
            !event.isEqual(
                toEvent: ScrollEvent(phase: .began, deltaX: 1.0, deltaY: 0.0, timestamp: 0.0)))
        #expect(
            !event.isEqual(
                toEvent: ScrollEvent(phase: .began, deltaX: 0.0, deltaY: 1.0, timestamp: 0.0)))
    }
}
