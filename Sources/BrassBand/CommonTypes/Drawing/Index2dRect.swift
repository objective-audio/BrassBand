import Foundation

extension Index2dRect: @retroactive Equatable {}

extension Index2dRect {
    public mutating func setAll(first: Index2d) {
        indices.0 = first
        indices.1 = first + 2
        indices.2 = first + 1
        indices.3 = first + 1
        indices.4 = first + 2
        indices.5 = first + 3
    }
}
