import Testing

@testable import BrassBand

struct EventInputTests {
    @MainActor
    @Test func inputTouchEvent() {
        let eventInput = EventInput()

        var events: [TouchEvent] = []

        let canceller = eventInput.touchPublisher.sink {
            events.append($0)
        }

        #expect(events.count == 0)

        let touchId = TouchId.mouseLeft

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: touchId, position: .zero, timestamp: 0))

        #expect(events.count == 1)
        #expect(events[0].touchId == touchId)
        #expect(events[0].phase == .began)

        eventInput.input(
            touchEvent: .init(phase: .began, touchId: touchId, position: .zero, timestamp: 0))

        #expect(events.count == 1)

        eventInput.input(
            touchEvent: .init(phase: .changed, touchId: touchId, position: .zero, timestamp: 0))

        #expect(events.count == 2)
        #expect(events[1].touchId == touchId)
        #expect(events[1].phase == .changed)

        eventInput.input(
            touchEvent: .init(phase: .ended, touchId: touchId, position: .zero, timestamp: 0))

        #expect(events.count == 3)
        #expect(events[2].touchId == touchId)
        #expect(events[2].phase == .ended)

        canceller.cancel()
    }

    @MainActor
    @Test func inputCursorEvent() {
        let eventInput = EventInput()

        var events: [CursorEvent] = []

        let canceller = eventInput.cursorPublisher.sink {
            events.append($0)
        }

        #expect(events.count == 0)

        eventInput.input(cursorPhase: .began, position: .zero, timestamp: 0)

        #expect(events.count == 1)
        #expect(events[0].phase == .began)

        eventInput.input(cursorPhase: .changed, position: .zero, timestamp: 0)

        #expect(events.count == 2)
        #expect(events[1].phase == .changed)

        eventInput.input(cursorPhase: .ended, position: .zero, timestamp: 0)

        #expect(events.count == 3)
        #expect(events[2].phase == .ended)

        eventInput.input(cursorPhase: .changed, position: .zero, timestamp: 0)
        eventInput.input(cursorPhase: .ended, position: .zero, timestamp: 0)

        #expect(events.count == 3)

        canceller.cancel()
    }

    @MainActor
    @Test func inputPinchEvent() {
        let eventInput = EventInput()

        var events: [PinchEvent] = []

        let canceller = eventInput.pinchPublisher.sink {
            events.append($0)
        }

        #expect(events.count == 0)

        eventInput.input(pinchEvent: .init(phase: .began, magnification: 0, timestamp: 0))

        #expect(events.count == 1)
        #expect(events[0].phase == .began)

        eventInput.input(pinchEvent: .init(phase: .changed, magnification: 0, timestamp: 0))

        #expect(events.count == 2)
        #expect(events[1].phase == .changed)

        eventInput.input(pinchEvent: .init(phase: .canceled, magnification: 0, timestamp: 0))

        #expect(events.count == 3)
        #expect(events[2].phase == .canceled)

        eventInput.input(pinchEvent: .init(phase: .began, magnification: 0, timestamp: 0))

        #expect(events.count == 4)
        #expect(events[3].phase == .began)

        eventInput.input(pinchEvent: .init(phase: .began, magnification: 0, timestamp: 0))

        #expect(events.count == 6)
        #expect(events[4].phase == .canceled)
        #expect(events[5].phase == .began)

        eventInput.input(pinchEvent: .init(phase: .ended, magnification: 0, timestamp: 0))

        #expect(events.count == 7)
        #expect(events[6].phase == .ended)

        canceller.cancel()
    }

    @MainActor
    @Test func inputScrollEvent() {
        let eventInput = EventInput()

        var events: [ScrollEvent] = []

        let canceller = eventInput.scrollPublisher.sink {
            events.append($0)
        }

        #expect(events.count == 0)

        eventInput.input(scrollEvent: .init(phase: .began, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 1)
        #expect(events[0].phase == .began)

        eventInput.input(scrollEvent: .init(phase: .changed, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 2)
        #expect(events[1].phase == .changed)

        eventInput.input(scrollEvent: .init(phase: .canceled, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 3)
        #expect(events[2].phase == .canceled)

        eventInput.input(scrollEvent: .init(phase: .began, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 4)
        #expect(events[3].phase == .began)

        eventInput.input(scrollEvent: .init(phase: .began, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 6)
        #expect(events[4].phase == .canceled)
        #expect(events[5].phase == .began)

        eventInput.input(scrollEvent: .init(phase: .ended, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 7)
        #expect(events[6].phase == .ended)

        eventInput.input(scrollEvent: .init(phase: .stationary, deltaX: 0, deltaY: 0, timestamp: 0))
        eventInput.input(scrollEvent: .init(phase: .changed, deltaX: 0, deltaY: 0, timestamp: 0))
        eventInput.input(scrollEvent: .init(phase: .ended, deltaX: 0, deltaY: 0, timestamp: 0))
        eventInput.input(scrollEvent: .init(phase: .canceled, deltaX: 0, deltaY: 0, timestamp: 0))
        eventInput.input(scrollEvent: .init(phase: .mayBegin, deltaX: 0, deltaY: 0, timestamp: 0))

        #expect(events.count == 7)

        canceller.cancel()
    }

    @MainActor
    @Test func inputKeyEvent() {
        let eventInput = EventInput()

        var events: [KeyEvent] = []

        let canceller = eventInput.keyPublisher.sink {
            events.append($0)
        }

        #expect(events.count == 0)

        eventInput.input(
            keyEvent: .init(
                phase: .began, keyCode: 0, characters: "0", rawCharacters: "0", timestamp: 0))

        #expect(events.count == 1)
        #expect(events[0].phase == .began)
        #expect(events[0].keyCode == 0)

        eventInput.input(
            keyEvent: .init(
                phase: .changed, keyCode: 0, characters: "0", rawCharacters: "0", timestamp: 0))

        #expect(events.count == 2)
        #expect(events[1].phase == .changed)
        #expect(events[1].keyCode == 0)

        eventInput.input(
            keyEvent: .init(
                phase: .began, keyCode: 1, characters: "1", rawCharacters: "1", timestamp: 0))

        #expect(events.count == 3)
        #expect(events[2].phase == .began)
        #expect(events[2].keyCode == 1)

        eventInput.input(
            keyEvent: .init(
                phase: .began, keyCode: 1, characters: "1", rawCharacters: "1", timestamp: 0))

        #expect(events.count == 5)
        #expect(events[3].phase == .ended)
        #expect(events[3].keyCode == 1)
        #expect(events[4].phase == .began)
        #expect(events[4].keyCode == 1)

        eventInput.input(
            keyEvent: .init(
                phase: .ended, keyCode: 1, characters: "1", rawCharacters: "1", timestamp: 0))

        #expect(events.count == 6)
        #expect(events[5].phase == .ended)
        #expect(events[5].keyCode == 1)

        eventInput.input(
            keyEvent: .init(
                phase: .ended, keyCode: 0, characters: "0", rawCharacters: "0", timestamp: 0))

        #expect(events.count == 7)
        #expect(events[6].phase == .ended)
        #expect(events[6].keyCode == 0)

        canceller.cancel()
    }

    @MainActor
    @Test func inputModifierEvent() {
        let eventInput = EventInput()

        var events: [ModifierEvent] = []

        let canceller = eventInput.modifierPublisher.sink {
            events.append($0)
        }

        #expect(events.count == 0)

        eventInput.input(modifierFlags: .shift, timestamp: 0)

        #expect(events.count == 1)
        #expect(events[0].phase == .began)
        #expect(events[0].flag == .shift)

        eventInput.input(modifierFlags: [.shift, .command], timestamp: 0)

        #expect(events.count == 2)
        #expect(events[1].phase == .began)
        #expect(events[1].flag == .command)

        eventInput.input(modifierFlags: .command, timestamp: 0)

        #expect(events.count == 3)
        #expect(events[2].phase == .ended)
        #expect(events[2].flag == .shift)

        eventInput.input(modifierFlags: [], timestamp: 0)

        #expect(events.count == 4)
        #expect(events[3].phase == .ended)
        #expect(events[3].flag == .command)

        canceller.cancel()
    }
}
