import Foundation

public struct PinchEvent: Sendable {
    public let phase: EventPhase
    public let magnification: Double
    public let timestamp: Double

    internal func phase(_ newPhase: EventPhase) -> Self {
        .init(phase: newPhase, magnification: magnification, timestamp: timestamp)
    }
}

extension PinchEvent: Event {
    func isEqual(toEvent other: PinchEvent) -> Bool {
        magnification == other.magnification
    }
}
