import Foundation

@MainActor
public final class EventInput {
    private var touchEvents: [TouchId: TouchEvent] = [:]
    private var cursorEvent: CursorEvent?
    private var scrollEvent: ScrollEvent?
    private var pinchEvent: PinchEvent?
    private var keyEvents: [UInt16: KeyEvent] = [:]
    private var modifierEvents: [UInt32: ModifierEvent] = [:]

    private let touchSubject: PassthroughSubject<TouchEvent, Never> = .init()
    public var touchPublisher: AnyPublisher<TouchEvent, Never> {
        touchSubject.eraseToAnyPublisher()
    }

    func input(touchEvent newTouchEvent: TouchEvent) {
        let id = newTouchEvent.touchId

        if newTouchEvent.phase == .began {
            guard touchEvents[id] == nil else { return }
        }

        if newTouchEvent.phase == .began || touchEvents[id] != nil {
            touchEvents[id] = newTouchEvent

            touchSubject.send(newTouchEvent)

            switch newTouchEvent.phase {
            case .ended, .canceled:
                touchEvents[id] = nil
            case .began, .changed, .mayBegin, .stationary:
                break
            }
        }
    }

    private let cursorSubject: PassthroughSubject<CursorEvent, Never> = .init()
    public var cursorPublisher: AnyPublisher<CursorEvent, Never> {
        cursorSubject.eraseToAnyPublisher()
    }

    func input(cursorPhase: CursorPhase, position: Point, timestamp: Double) {
        let phase: CursorPhase

        let containsInWindow = Region(center: .zero, size: .init(repeating: 2.0)).contains(position)
        if containsInWindow, cursorPhase != .ended {
            if cursorEvent != nil {
                phase = .changed
            } else if cursorPhase == .began {
                phase = .began
            } else {
                return
            }
        } else {
            phase = .ended
        }

        let cursorEvent: CursorEvent

        if phase == .began {
            cursorEvent = .init(phase: .began, position: position, timestamp: timestamp)
        } else if let prevCursorEvent = self.cursorEvent {
            if phase == .ended {
                cursorEvent = .init(
                    phase: phase, position: prevCursorEvent.position,
                    timestamp: timestamp)
            } else {
                cursorEvent = .init(phase: phase, position: position, timestamp: timestamp)
            }
        } else {
            return
        }

        self.cursorEvent = cursorEvent

        cursorSubject.send(cursorEvent)

        if phase == .ended {
            self.cursorEvent = nil
        }
    }

    private let pinchSubject: PassthroughSubject<PinchEvent, Never> = .init()
    public var pinchPublisher: AnyPublisher<PinchEvent, Never> {
        pinchSubject.eraseToAnyPublisher()
    }

    func input(pinchEvent newPinchEvent: PinchEvent) {
        if newPinchEvent.phase == .began {
            if let pinchEvent {
                pinchSubject.send(pinchEvent.phase(.canceled))
                self.pinchEvent = nil
            }
        }

        guard newPinchEvent.phase == .began || self.pinchEvent != nil else { return }

        self.pinchEvent = newPinchEvent

        pinchSubject.send(newPinchEvent)

        if newPinchEvent.phase == .canceled || newPinchEvent.phase == .ended {
            self.pinchEvent = nil
        }
    }

    private let scrollSubject: PassthroughSubject<ScrollEvent, Never> = .init()
    public var scrollPublisher: AnyPublisher<ScrollEvent, Never> {
        scrollSubject.eraseToAnyPublisher()
    }

    func input(scrollEvent newScrollEvent: ScrollEvent) {
        if newScrollEvent.phase == .began {
            if let scrollEvent {
                scrollSubject.send(scrollEvent.phase(.canceled))
                self.scrollEvent = nil
            }
        }

        guard newScrollEvent.phase == .began || self.scrollEvent != nil else {
            return
        }

        let outPhase: EventPhase = {
            if newScrollEvent.phase == .began {
                return .began
            } else if newScrollEvent.phase == .ended {
                return .ended
            } else if newScrollEvent.phase == .canceled {
                return .canceled
            } else {
                return .changed
            }
        }()

        let scrollEvent = newScrollEvent.phase(outPhase)
        self.scrollEvent = scrollEvent

        scrollSubject.send(scrollEvent)

        if outPhase == .ended || outPhase == .canceled {
            self.scrollEvent = nil
        }
    }

    private let keySubject: PassthroughSubject<KeyEvent, Never> = .init()
    public var keyPublisher: AnyPublisher<KeyEvent, Never> {
        keySubject.eraseToAnyPublisher()
    }

    func input(keyEvent newKeyEvent: KeyEvent) {
        let keyCode = newKeyEvent.keyCode

        if newKeyEvent.phase == .began {
            if let keyEvent = self.keyEvents[keyCode] {
                keySubject.send(keyEvent.phase(.ended))
                keyEvents[keyCode] = nil
            }
        }

        if newKeyEvent.phase == .began || self.keyEvents[keyCode] != nil {
            self.keyEvents[keyCode] = newKeyEvent

            keySubject.send(newKeyEvent)

            if newKeyEvent.phase == .ended || newKeyEvent.phase == .canceled {
                keyEvents[keyCode] = nil
            }
        }
    }

    private let modifierSubject: PassthroughSubject<ModifierEvent, Never> = .init()
    public var modifierPublisher: AnyPublisher<ModifierEvent, Never> {
        modifierSubject.eraseToAnyPublisher()
    }

    func input(modifierFlags: ModifierFlag, timestamp: Double) {
        for flag in ModifierFlag.allArray {
            if modifierFlags.contains(flag) {
                if modifierEvents[flag.rawValue] == nil {
                    let modifierEvent = ModifierEvent(
                        phase: .began, flag: flag, timestamp: timestamp)
                    modifierEvents[flag.rawValue] = modifierEvent
                    modifierSubject.send(modifierEvent)
                }
            } else {
                if let modifierEvent = modifierEvents[flag.rawValue] {
                    modifierSubject.send(modifierEvent.phase(.ended))
                    modifierEvents[flag.rawValue] = nil
                }
            }
        }
    }
}
