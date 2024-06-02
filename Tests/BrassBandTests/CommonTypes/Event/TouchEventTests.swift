import Testing

@testable import BrassBand

struct TouchEventTests {
    @Test func isEqual() {
        let event = TouchEvent(phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0.0)

        // touchIdが同じならtrue
        #expect(
            event.isEqual(
                toEvent: TouchEvent(
                    phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 0.0)))
        #expect(
            event.isEqual(
                toEvent: TouchEvent(
                    phase: .ended, touchId: .mouseLeft, position: .zero, timestamp: 0.0)))
        #expect(
            event.isEqual(
                toEvent: TouchEvent(
                    phase: .began, touchId: .mouseLeft, position: .init(repeating: 1.0),
                    timestamp: 0.0)))
        #expect(
            event.isEqual(
                toEvent: TouchEvent(
                    phase: .began, touchId: .mouseLeft, position: .zero, timestamp: 1.0)))

        // touchIdが違うとfalse
        #expect(
            !event.isEqual(
                toEvent: TouchEvent(
                    phase: .began, touchId: .mouseRight, position: .zero, timestamp: 0.0)))
    }
}
