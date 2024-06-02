import Combine
import Foundation

@MainActor
public final class LayoutRegionGuide {
    public let horizontalRange: LayoutRangeGuide
    public let verticalRange: LayoutRangeGuide

    @CurrentValue private var suspendCount: Int = 0

    public init(_ region: Region = .zero) {
        horizontalRange = .init(region.horizontalRange)
        verticalRange = .init(region.verticalRange)
    }

    convenience public init(_ ranges: Region.Ranges) {
        self.init(.init(ranges: ranges))
    }

    public var leftGuide: LayoutValueGuide { horizontalRange.minGuide }
    public var rightGuide: LayoutValueGuide { horizontalRange.maxGuide }
    public var bottomGuide: LayoutValueGuide { verticalRange.minGuide }
    public var topGuide: LayoutValueGuide { verticalRange.maxGuide }
    public var widthSource: any LayoutValueSource { horizontalRange.layoutLengthValueSource }
    public var heightSource: any LayoutValueSource { verticalRange.layoutLengthValueSource }

    public var region: Region {
        get { .init(horizontalRange: horizontalRange.range, verticalRange: verticalRange.range) }
        set {
            setRanges(.init(vertical: newValue.verticalRange, horizontal: newValue.horizontalRange))
        }
    }

    public var regionPublisher: AnyPublisher<Region, Never> {
        horizontalRange.rangePublisher.combineLatest(
            verticalRange.rangePublisher, $suspendCount
        ).compactMap { (horizontal, vertical, suspendCount) -> Region? in
            guard suspendCount == 0 else { return nil }
            return .init(ranges: .init(vertical: vertical, horizontal: horizontal))
        }.removeDuplicates().eraseToAnyPublisher()
    }

    public func setRanges(_ ranges: Region.Ranges) {
        suspendNotify {
            horizontalRange.range = ranges.horizontal
            verticalRange.range = ranges.vertical
        }
    }
}

extension LayoutRegionGuide {
    func suspendNotify(_ suspending: () -> Void) {
        suspendCount += 1
        horizontalRange.suspendNotify {
            verticalRange.suspendNotify {
                suspending()
            }
        }
        suspendCount -= 1
    }
}

extension LayoutRegionGuide: LayoutRegionTarget {
    public func setLayoutRegion(_ region: Region) {
        self.region = region
    }
}

extension LayoutRegionGuide: LayoutRegionSource {
    public var layoutRegionPublisher: AnyPublisher<Region, Never> {
        regionPublisher.eraseToAnyPublisher()
    }

    public var layoutHorizontalRangeSource: any LayoutRangeSource { horizontalRange }
    public var layoutVerticalRangeSource: any LayoutRangeSource { verticalRange }
}
