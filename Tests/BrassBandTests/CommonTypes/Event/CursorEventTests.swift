import Testing

@testable import BrassBand

struct CursorEventTests {
    @Test func phase() async throws {
        let event = CursorEvent(phase: .began, position: .zero, timestamp: 0.0)

        let phaseReplaced = event.phase(.ended)
        #expect(phaseReplaced.phase == .ended)
        #expect(phaseReplaced.position == .zero)
        #expect(phaseReplaced.timestamp == 0.0)
    }

    @Test func isEqual() {
        let event = CursorEvent(phase: .began, position: .zero, timestamp: 0.0)

        // Cursorは1つなので常に同じ判定をする
        #expect(event.isEqual(toEvent: CursorEvent(phase: .began, position: .zero, timestamp: 0.0)))
        #expect(event.isEqual(toEvent: CursorEvent(phase: .ended, position: .zero, timestamp: 0.0)))
        #expect(
            event.isEqual(
                toEvent: CursorEvent(phase: .began, position: .init(repeating: 1.0), timestamp: 0.0)
            ))
        #expect(event.isEqual(toEvent: CursorEvent(phase: .began, position: .zero, timestamp: 2.0)))
    }
}
