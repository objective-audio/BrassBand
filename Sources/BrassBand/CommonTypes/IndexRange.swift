import Foundation

public struct IndexRange: Sendable {
    public var index: Int
    public var length: Int

    public init(index: Int, length: Int) {
        self.index = index
        self.length = length
    }

    public var next: Int { index + length }

    public static let zero: IndexRange = .init(index: 0, length: 0)

    public func contains(_ index: Int) -> Bool {
        self.index <= index && index < self.next
    }
}

extension IndexRange: Equatable {}
