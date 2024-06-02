import Combine
import Foundation

@MainActor
public final class LayoutValueGuide {
    @CurrentValue private var rawValue: Float
    @CurrentValue private var suspendCount: Int = 0

    public var value: Float {
        get { rawValue }
        set { rawValue = newValue }
    }
    public var valuePublisher: AnyPublisher<Float, Never> {
        $rawValue.combineLatest($suspendCount).compactMap { (value, suspendCount) -> Float? in
            suspendCount == 0 ? value : nil
        }.removeDuplicates().eraseToAnyPublisher()
    }

    public init(_ value: Float = 0.0) {
        self.rawValue = value
    }

    func suspendNotify(_ suspending: () -> Void) {
        suspendCount += 1
        suspending()
        suspendCount -= 1
    }
}

extension LayoutValueGuide: LayoutValueTarget {
    public func setLayoutValue(_ value: Float) {
        self.rawValue = value
    }
}

extension LayoutValueGuide: LayoutValueSource {
    public var layoutValue: Float { rawValue }
    public var layoutValuePublisher: AnyPublisher<Float, Never> { valuePublisher }
}
