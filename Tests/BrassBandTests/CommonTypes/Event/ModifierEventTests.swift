import Testing

@testable import BrassBand

struct ModifierEventTests {
    @Test func phase() {
        let event = ModifierEvent(phase: .began, flag: .alphaShift, timestamp: 0.0)

        let phaseReplaced = event.phase(.ended)
        #expect(phaseReplaced.phase == .ended)
        #expect(phaseReplaced.flag == .alphaShift)
        #expect(phaseReplaced.timestamp == 0.0)
    }

    @Test func isEqual() {
        let event = ModifierEvent(phase: .began, flag: .alphaShift, timestamp: 0.0)

        // flagが同じならtrue
        #expect(
            event.isEqual(toEvent: ModifierEvent(phase: .began, flag: .alphaShift, timestamp: 0.0)))
        #expect(
            event.isEqual(toEvent: ModifierEvent(phase: .ended, flag: .alphaShift, timestamp: 0.0)))
        #expect(
            event.isEqual(toEvent: ModifierEvent(phase: .began, flag: .alphaShift, timestamp: 1.0)))

        // flagが違うならfalse
        #expect(
            !event.isEqual(toEvent: ModifierEvent(phase: .began, flag: .alternate, timestamp: 0.0)))
    }

    @Test func flagDescriptionEmpty() {
        #expect(ModifierFlag().description == "")
        #expect(ModifierFlag(rawValue: 1).description == "")
    }

    @Test func flagDescriptionAll() {
        let event: ModifierFlag = [
            .alphaShift, .shift, .control, .alternate, .command, .numericPad, .help, .function,
        ]
        #expect(
            event.description
                == "alphaShift|shift|control|alternate|command|numericPad|help|function")
    }
}
