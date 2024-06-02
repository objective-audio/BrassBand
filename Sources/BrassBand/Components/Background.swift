import Combine
import Foundation

@MainActor
public final class Background {
    private var updates: BackgroundUpdateReason = .all
    private var cancellables: Set<AnyCancellable> = .init()

    public var color: Color = .init(repeating: 1.0) {
        didSet { updates.insert(.color) }
    }
}

extension Background {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {
        treeUpdates.backgroundUpdates.formUnion(updates)
    }

    func clearUpdates() {
        updates = .init()
    }
}
