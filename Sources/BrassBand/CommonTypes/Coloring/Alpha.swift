import Foundation

public struct Alpha: Sendable, Equatable {
    public var value: Float = 1.0

    public init(value: Float) {
        self.value = max(value, 0.0)
    }

    public static var zero: Alpha { .init(value: 0.0) }
    public static var one: Alpha { .init(value: 1.0) }
}
