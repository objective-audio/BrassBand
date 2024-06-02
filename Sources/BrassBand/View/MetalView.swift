import Foundation
import MetalKit

@MainActor
public protocol MetalViewDelegate: AnyObject {
    func metalView(_ view: MetalView, safeAreaInsetsDidChange insets: RegionInsets)
}

public final class MetalView: MTKView {
    public weak var uiDelegate: (any MetalViewDelegate)?

    var eventInput: EventInput?

    #if os(iOS)

        public override var canBecomeFirstResponder: Bool {
            return true
        }

        public var uiAppearance: Appearance {
            switch self.traitCollection.userInterfaceStyle {
            case .dark:
                return .dark
            case .unspecified, .light:
                return .normal
            @unknown default:
                return .normal
            }
        }

        public var uiSafeAreaInsets: RegionInsets {
            let insets = safeAreaInsets
            return .init(
                left: Float(insets.left), right: Float(insets.right), bottom: Float(insets.bottom),
                top: Float(insets.top))
        }

        public override func safeAreaInsetsDidChange() {
            uiDelegate?.metalView(self, safeAreaInsetsDidChange: uiSafeAreaInsets)
        }

        public override var drawableSize: CGSize {
            get {
                let viewSize = frame.size
                let scale = contentScaleFactor
                return .init(
                    width: round(viewSize.width * scale), height: round(viewSize.height * scale))
            }
            set {}
        }

    #elseif os(macOS)

        public override var acceptsFirstResponder: Bool {
            true
        }

        public var uiAppearance: Appearance {
            let name = effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
            return name == .darkAqua ? .dark : .normal
        }

        public var uiSafeAreaInsets: RegionInsets { .zero }

        private var trackingArea: NSTrackingArea?

    #endif

    func configure() {
        #if os(iOS)
            let gesture = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
            addGestureRecognizer(gesture)
        #endif
    }

    func viewLocationFromUIPosition(_ position: Point) -> Point {
        let viewSize = bounds.size
        let locationX = (1.0 + position.x) * Float(viewSize.width) * 0.5
        let y = (1.0 + position.y) * Float(viewSize.height) * 0.5

        #if os(iOS)
            let locationY = Float(viewSize.height) - y
        #elseif os(macOS)
            let locationY = y
        #endif

        return .init(x: locationX, y: locationY)
    }

    func uiPositionFromViewLocation(_ location: Point) -> Point {
        let viewSize = bounds.size

        #if os(iOS)
            let locationY = Float(viewSize.height) - location.y
        #elseif os(macOS)
            let locationY = location.y
        #endif

        return .init(
            x: location.x / Float(viewSize.width) * 2.0 - 1.0,
            y: locationY / Float(viewSize.height) * 2.0 - 1.0)
    }
}

extension MetalView {
    #if os(iOS)
        private func sendTouchEvent(touch: UITouch, phase: EventPhase) {
            guard let eventInput else { return }
            eventInput.input(
                touchEvent: .init(
                    phase: phase, touchId: .touch(ObjectIdentifier(touch)),
                    position: position(touch: touch), timestamp: touch.timestamp))
        }

        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                sendTouchEvent(touch: touch, phase: .began)
            }
        }

        public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                sendTouchEvent(touch: touch, phase: .ended)
            }
        }

        public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                sendTouchEvent(touch: touch, phase: .changed)
                sendCursorEvent(position: position(touch: touch), phase: .changed)
            }
        }

        public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                sendTouchEvent(touch: touch, phase: .canceled)
            }
        }

    #elseif os(macOS)

        public override func updateTrackingAreas() {
            super.updateTrackingAreas()

            if let trackingArea {
                removeTrackingArea(trackingArea)
                self.trackingArea = nil
            }

            let trackingArea = NSTrackingArea(
                rect: self.bounds,
                options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self,
                userInfo: nil)
            self.trackingArea = trackingArea

            addTrackingArea(trackingArea)
        }

        override public func mouseDown(with event: NSEvent) {
            sendModifierEvent(event)
            sendTouchEvent(event, phase: .began)
        }

        override public func rightMouseDown(with event: NSEvent) {
            sendModifierEvent(event)
            sendTouchEvent(event, phase: .began)
        }

        override public func otherMouseDown(with event: NSEvent) {
            sendModifierEvent(event)
            sendTouchEvent(event, phase: .began)
        }

        override public func mouseUp(with event: NSEvent) {
            sendModifierEvent(event)
            sendTouchEvent(event, phase: .ended)
        }

        override public func rightMouseUp(with event: NSEvent) {
            sendModifierEvent(event)
            sendTouchEvent(event, phase: .ended)
        }

        override public func otherMouseUp(with event: NSEvent) {
            sendModifierEvent(event)
            sendTouchEvent(event, phase: .ended)
        }

        override public func mouseEntered(with event: NSEvent) {
            sendModifierEvent(event)
            sendCursorEvent(event)
        }

        override public func mouseMoved(with event: NSEvent) {
            sendModifierEvent(event)
            sendCursorEvent(event)
        }

        override public func mouseExited(with event: NSEvent) {
            sendModifierEvent(event)
            sendCursorEvent(event)
        }

        override public func mouseDragged(with event: NSEvent) {
            sendModifierEvent(event)
            sendCursorEvent(event)
            sendTouchEvent(event, phase: .changed)
        }

        override public func rightMouseDragged(with event: NSEvent) {
            sendModifierEvent(event)
            sendCursorEvent(event)
            sendTouchEvent(event, phase: .changed)
        }

        override public func otherMouseDragged(with event: NSEvent) {
            sendModifierEvent(event)
            sendCursorEvent(event)
            sendTouchEvent(event, phase: .changed)
        }

        override public func scrollWheel(with event: NSEvent) {
            sendScrollEvent(event)
        }

        override public func magnify(with event: NSEvent) {
            sendPinchEvent(event)
        }

        override public func keyDown(with event: NSEvent) {
            sendModifierEvent(event)
            sendKeyEvent(event, phase: event.isARepeat ? .changed : .began)
        }

        override public func keyUp(with event: NSEvent) {
            sendModifierEvent(event)
            sendKeyEvent(event, phase: .ended)
        }

        override public func flagsChanged(with event: NSEvent) {
            sendModifierEvent(event)
        }

    #endif
}

extension MetalView {
    #if os(iOS)

        private func position(touch: UITouch) -> Point {
            let locationInView = touch.location(in: self)
            let location = Point(x: Float(locationInView.x), y: Float(locationInView.y))
            return uiPositionFromViewLocation(location)
        }

        private func position(hover gesture: UIHoverGestureRecognizer) -> Point {
            let locationInView = gesture.location(in: self)
            let location = Point(x: Float(locationInView.x), y: Float(locationInView.y))
            return uiPositionFromViewLocation(location)
        }

        private func sendCursorEvent(position: Point, phase: CursorPhase) {
            guard let eventInput else { return }
            eventInput.input(
                cursorPhase: phase, position: position, timestamp: ProcessInfo().systemUptime)
        }

        @objc private func handleHover(_ gesture: UIHoverGestureRecognizer) {
            let position = position(hover: gesture)

            switch gesture.state {
            case .began, .changed:
                sendCursorEvent(position: position, phase: .began)
            case .ended, .cancelled, .failed:
                sendCursorEvent(position: position, phase: .ended)
            case .possible:
                break
            @unknown default:
                break
            }
        }

    #elseif os(macOS)

        private func sendTouchEvent(_ event: NSEvent, phase: EventPhase) {
            guard let eventInput else { return }
            let touchEvent = TouchEvent(
                phase: phase,
                touchId: .mouse(event.buttonNumber), position: position(event: event),
                timestamp: event.timestamp)
            eventInput.input(touchEvent: touchEvent)
        }

        private func sendCursorEvent(_ event: NSEvent) {
            guard let eventInput else { return }
            eventInput.input(
                cursorPhase: .began, position: position(event: event), timestamp: event.timestamp)
        }

        private func sendScrollEvent(_ event: NSEvent) {
            guard event.hasPreciseScrollingDeltas, let eventInput else { return }
            guard let phase = EventPhase(event.phase) ?? EventPhase(event.momentumPhase) else {
                return
            }
            let scrollEvent = ScrollEvent(
                phase: phase,
                deltaX: event.scrollingDeltaX, deltaY: event.scrollingDeltaY,
                timestamp: event.timestamp)
            eventInput.input(scrollEvent: scrollEvent)
        }

        private func sendPinchEvent(_ event: NSEvent) {
            guard let eventInput, let phase = EventPhase(event.phase) else { return }
            let pinchEvent = PinchEvent(
                phase: phase,
                magnification: event.magnification, timestamp: event.timestamp)
            eventInput.input(pinchEvent: pinchEvent)
        }

        private func sendKeyEvent(_ event: NSEvent, phase: EventPhase) {
            guard let eventInput else { return }
            let keyEvent = KeyEvent(
                phase: phase,
                keyCode: event.keyCode, characters: event.characters ?? "",
                rawCharacters: event.charactersIgnoringModifiers ?? "",
                timestamp: event.timestamp)
            eventInput.input(keyEvent: keyEvent)
        }

        private func sendModifierEvent(_ event: NSEvent) {
            guard let eventInput else { return }
            eventInput.input(modifierFlags: .init(event.modifierFlags), timestamp: event.timestamp)
        }

        private func position(event: NSEvent) -> Point {
            let locationInView = convert(event.locationInWindow, from: nil)
            let location = Point(x: Float(locationInView.x), y: Float(locationInView.y))
            return uiPositionFromViewLocation(location)
        }

    #endif
}

extension EventPhase {
    #if os(iOS)

    #elseif os(macOS)

        fileprivate init?(_ phase: NSEvent.Phase) {
            switch phase {
            case .began:
                self = .began
            case .ended:
                self = .ended
            case .changed:
                self = .changed
            case .stationary:
                self = .stationary
            case .cancelled:
                self = .canceled
            case .mayBegin:
                self = .mayBegin
            default:
                return nil
            }
        }

    #endif
}

extension ModifierFlag {
    #if os(iOS)

    #elseif os(macOS)

        fileprivate init(_ flags: NSEvent.ModifierFlags) {
            self.init(rawValue: UInt32(flags.rawValue))
        }

    #endif
}
