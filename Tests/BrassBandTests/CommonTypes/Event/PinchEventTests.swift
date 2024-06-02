import Testing

@testable import BrassBand

struct PinchEventTests {
    @Test func phase() {
        let event = PinchEvent(phase: .began, magnification: 0.0, timestamp: 0.0)

        let phaseReplaced = event.phase(.ended)
        #expect(phaseReplaced.phase == .ended)
        #expect(phaseReplaced.magnification == 0.0)
        #expect(phaseReplaced.timestamp == 0.0)
    }

    @Test func isEqual() {
        let event = PinchEvent(phase: .began, magnification: 0.0, timestamp: 0.0)

        // magnificationが同じならtrue
        #expect(
            event.isEqual(toEvent: PinchEvent(phase: .began, magnification: 0.0, timestamp: 0.0)))
        #expect(
            event.isEqual(toEvent: PinchEvent(phase: .began, magnification: 0.0, timestamp: 0.0)))
        #expect(
            event.isEqual(toEvent: PinchEvent(phase: .began, magnification: 0.0, timestamp: 1.0)))

        // magnificationが違うならfalse
        #expect(
            !event.isEqual(toEvent: PinchEvent(phase: .began, magnification: 1.0, timestamp: 0.0)))
    }
}
