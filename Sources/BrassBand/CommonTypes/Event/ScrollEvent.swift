import Foundation

public struct ScrollEvent: Sendable {
    public let phase: EventPhase
    public let deltaX: Double
    public let deltaY: Double
    public let timestamp: Double

    internal func phase(_ newPhase: EventPhase) -> Self {
        .init(phase: newPhase, deltaX: deltaX, deltaY: deltaY, timestamp: timestamp)
    }
}

extension ScrollEvent: Event {
    func isEqual(toEvent other: ScrollEvent) -> Bool {
        deltaX == other.deltaX && deltaY == other.deltaY
    }
}
