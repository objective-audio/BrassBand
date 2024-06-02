import Foundation

public struct TextureUsage: OptionSet, Sendable {
    public let rawValue: Int

    public static let shaderRead = Self(rawValue: 1 << 0)
    public static let shaderWrite = Self(rawValue: 1 << 1)
    public static let renderTarget = Self(rawValue: 1 << 2)

    public static let all: Self = [.shaderRead, .shaderWrite, .renderTarget]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
