import Foundation

public struct CursorEvent: Sendable {
    public let phase: CursorPhase
    public let position: Point
    public let timestamp: Double

    internal func phase(_ newPhase: CursorPhase) -> Self {
        .init(phase: newPhase, position: position, timestamp: timestamp)
    }
}

extension CursorEvent: Event {
    func isEqual(toEvent other: CursorEvent) -> Bool {
        true
    }
}
