import Testing

@testable import BrassBand

struct KeyEventTests {
    @Test func phase() {
        let event = KeyEvent(
            phase: .began, keyCode: 0, characters: "c", rawCharacters: "rc", timestamp: 0.0)

        let phaseReplaced = event.phase(.ended)
        #expect(phaseReplaced.phase == .ended)
        #expect(phaseReplaced.keyCode == 0)
        #expect(phaseReplaced.characters == "c")
        #expect(phaseReplaced.rawCharacters == "rc")
        #expect(phaseReplaced.timestamp == 0.0)
    }

    @Test func isEqual() {
        let event = KeyEvent(
            phase: .began, keyCode: 0, characters: "c", rawCharacters: "rc", timestamp: 0.0)

        // keyCodeが同じならtrue
        #expect(
            event.isEqual(
                toEvent: KeyEvent(
                    phase: .began, keyCode: 0, characters: "c", rawCharacters: "rc", timestamp: 0.0)
            ))
        #expect(
            event.isEqual(
                toEvent: KeyEvent(
                    phase: .ended, keyCode: 0, characters: "c", rawCharacters: "rc", timestamp: 0.0)
            ))
        #expect(
            event.isEqual(
                toEvent: KeyEvent(
                    phase: .began, keyCode: 0, characters: "c2", rawCharacters: "rc", timestamp: 0.0
                )))
        #expect(
            event.isEqual(
                toEvent: KeyEvent(
                    phase: .began, keyCode: 0, characters: "c", rawCharacters: "rc2", timestamp: 0.0
                )))
        #expect(
            event.isEqual(
                toEvent: KeyEvent(
                    phase: .began, keyCode: 0, characters: "c", rawCharacters: "rc", timestamp: 1.0)
            ))

        // keyCodeが違うならfalse
        #expect(
            !event.isEqual(
                toEvent: KeyEvent(
                    phase: .began, keyCode: 1, characters: "c", rawCharacters: "rc", timestamp: 0.0)
            ))
    }
}
