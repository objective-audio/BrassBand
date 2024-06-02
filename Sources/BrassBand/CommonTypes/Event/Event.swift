import Foundation

protocol Event {
    func isEqual(toEvent other: Self) -> Bool
}
