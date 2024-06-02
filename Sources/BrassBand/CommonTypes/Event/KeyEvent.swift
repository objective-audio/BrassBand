import Foundation

public struct KeyEvent: Sendable {
    public let phase: EventPhase
    public let keyCode: UInt16
    public let characters: String
    public let rawCharacters: String
    public let timestamp: Double

    internal func phase(_ newPhase: EventPhase) -> Self {
        .init(
            phase: newPhase, keyCode: keyCode, characters: characters, rawCharacters: rawCharacters,
            timestamp: timestamp)
    }
}

extension KeyEvent: Event {
    func isEqual(toEvent other: KeyEvent) -> Bool {
        keyCode == other.keyCode
    }
}
