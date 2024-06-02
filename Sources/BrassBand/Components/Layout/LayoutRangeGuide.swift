import Combine
import Foundation

@MainActor
public final class LayoutRangeGuide {
    public let minGuide: LayoutValueGuide
    public let maxGuide: LayoutValueGuide
    private let lengthGuide: LayoutValueGuide

    @CurrentValue private var suspendCount: Int = 0

    public var min: Float { minGuide.value }
    public var max: Float { maxGuide.value }
    public var length: Float { lengthGuide.value }

    public var range: Range {
        get {
            let min = self.min
            let max = self.max
            return .init(location: min, length: max - min)
        }
        set {
            suspendNotify {
                minGuide.value = newValue.min
                maxGuide.value = newValue.max
            }
        }
    }

    public var rangePublisher: AnyPublisher<Range, Never> {
        minGuide.valuePublisher.combineLatest(maxGuide.valuePublisher, $suspendCount).compactMap {
            (min, max, suspendCount) -> Range? in
            guard suspendCount == 0 else { return nil }
            return .init(location: min, length: max - min)
        }.removeDuplicates().eraseToAnyPublisher()
    }

    private var cancellables: Set<AnyCancellable> = []

    public init(_ range: Range = .zero) {
        minGuide = .init(range.min)
        maxGuide = .init(range.max)
        lengthGuide = .init(range.length)

        minGuide.valuePublisher.sink { [weak self] min in
            guard let self else { return }
            let max = Swift.max(min, self.max)
            self.suspendNotify {
                self.maxGuide.value = max
                self.lengthGuide.value = max - min
            }
        }.store(in: &cancellables)

        maxGuide.valuePublisher.sink { [weak self] max in
            guard let self else { return }
            let min = Swift.min(self.min, max)
            self.suspendNotify {
                self.minGuide.value = min
                self.lengthGuide.value = max - min
            }
        }.store(in: &cancellables)
    }

    func suspendNotify(_ suspending: () -> Void) {
        suspendCount += 1
        minGuide.suspendNotify {
            maxGuide.suspendNotify {
                lengthGuide.suspendNotify {
                    suspending()
                }
            }
        }
        suspendCount -= 1
    }
}

extension LayoutRangeGuide: LayoutRangeTarget {
    public func setLayoutRange(_ range: Range) {
        self.range = range
    }
}

extension LayoutRangeGuide: LayoutRangeSource {
    public var layoutRangePublisher: AnyPublisher<Range, Never> { rangePublisher }
    public var layoutMinValueSource: any LayoutValueSource { minGuide }
    public var layoutMaxValueSource: any LayoutValueSource { maxGuide }
    public var layoutLengthValueSource: any LayoutValueSource { lengthGuide }
}
