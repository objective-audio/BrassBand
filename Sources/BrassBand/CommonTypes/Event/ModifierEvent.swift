import Foundation

public struct ModifierFlag: OptionSet, Sendable, Hashable {
    public let rawValue: UInt32

    public static let alphaShift = Self(rawValue: 1 << 16)
    public static let shift = Self(rawValue: 1 << 17)
    public static let control = Self(rawValue: 1 << 18)
    public static let alternate = Self(rawValue: 1 << 19)
    public static let command = Self(rawValue: 1 << 20)
    public static let numericPad = Self(rawValue: 1 << 21)
    public static let help = Self(rawValue: 1 << 22)
    public static let function = Self(rawValue: 1 << 23)

    public static let all: Self = .init(allArray)
    public static let allArray: [ModifierFlag] = [
        .alphaShift, .shift, .control, .alternate, .command, .numericPad, .help, .function,
    ]

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public struct ModifierEvent: Sendable {
    public let phase: EventPhase
    public let flag: ModifierFlag
    public let timestamp: Double

    internal func phase(_ newPhase: EventPhase) -> Self {
        .init(phase: newPhase, flag: flag, timestamp: timestamp)
    }
}

extension ModifierEvent: Event {
    func isEqual(toEvent other: ModifierEvent) -> Bool {
        flag == other.flag
    }
}

extension ModifierFlag: CustomStringConvertible {
    public var description: String {
        ModifierFlag.allArray.compactMap {
            if self.contains($0) {
                switch $0 {
                case .alphaShift: return "alphaShift"
                case .shift: return "shift"
                case .control: return "control"
                case .alternate: return "alternate"
                case .command: return "command"
                case .numericPad: return "numericPad"
                case .help: return "help"
                case .function: return "function"
                default:
                    return nil
                }
            } else {
                return nil
            }
        }.joined(separator: "|")
    }
}
