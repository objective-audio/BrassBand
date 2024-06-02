import Foundation

extension OptionSet {
    func andTest(_ other: Self) -> Bool {
        !intersection(other).isEmpty
    }
}
