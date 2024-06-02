import Foundation

public enum TouchId: Sendable, Hashable, Comparable {
    case touch(ObjectIdentifier)
    case mouse(Int)

    public static let mouseLeft: TouchId = .mouse(0)
    public static let mouseRight: TouchId = .mouse(1)
}

public struct TouchEvent: Sendable {
    public let phase: EventPhase
    public let touchId: TouchId
    public let position: Point
    public let timestamp: Double
}

extension TouchEvent: Event {
    func isEqual(toEvent other: Self) -> Bool {
        touchId == other.touchId
    }
}
