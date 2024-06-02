import Foundation

public final class ActionGroup: Sendable {
    public init() {}
}

extension ActionGroup: Equatable {
    public static func == (lhs: ActionGroup, rhs: ActionGroup) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
