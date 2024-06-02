import Combine
import Foundation

@MainActor
public final class LayoutPointGuide {
    public let xGuide: LayoutValueGuide
    public let yGuide: LayoutValueGuide

    @CurrentValue private var suspendCount: Int = 0

    public var point: Point {
        get { .init(x: xGuide.value, y: yGuide.value) }
        set {
            suspendNotify {
                xGuide.value = newValue.x
                yGuide.value = newValue.y
            }
        }
    }
    public var pointPublisher: AnyPublisher<Point, Never> {
        return xGuide.valuePublisher.combineLatest(yGuide.valuePublisher, $suspendCount).compactMap
        {
            (x, y, suspendCount) -> Point? in
            suspendCount == 0 ? .init(x: x, y: y) : nil
        }.removeDuplicates().eraseToAnyPublisher()
    }

    public init(_ point: Point = .zero) {
        xGuide = .init(point.x)
        yGuide = .init(point.y)
    }

    func suspendNotify(_ suspending: () -> Void) {
        suspendCount += 1
        xGuide.suspendNotify {
            yGuide.suspendNotify {
                suspending()
            }
        }
        suspendCount -= 1
    }
}

extension LayoutPointGuide: LayoutPointTarget {
    public func setLayoutPoint(_ point: Point) {
        self.point = point
    }
}

extension LayoutPointGuide: LayoutPointSource {
    public var layoutPointPublisher: AnyPublisher<Point, Never> { pointPublisher }
    public var layoutXValueSource: any LayoutValueSource { xGuide }
    public var layoutYValueSource: any LayoutValueSource { yGuide }
}
