import Foundation

public struct StringsAttribute: Sendable {
    public var range: IndexRange?
    public var color: Color

    public init(range: IndexRange? = nil, color: Color = .init(rgb: .white, alpha: .one)) {
        self.range = range
        self.color = color
    }
}

extension StringsAttribute: Equatable {}
