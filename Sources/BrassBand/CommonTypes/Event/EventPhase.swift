import Foundation

public enum EventPhase: Sendable {
    case began, stationary, changed, ended, canceled, mayBegin
}
