import Combine
import Foundation

@MainActor
public protocol LayoutValueSource {
    var layoutValue: Float { get }
    var layoutValuePublisher: AnyPublisher<Float, Never> { get }
}

@MainActor
public protocol LayoutPointSource {
    var layoutPointPublisher: AnyPublisher<Point, Never> { get }
    var layoutXValueSource: any LayoutValueSource { get }
    var layoutYValueSource: any LayoutValueSource { get }
}

@MainActor
public protocol LayoutRangeSource {
    var layoutRangePublisher: AnyPublisher<Range, Never> { get }
    var layoutMinValueSource: any LayoutValueSource { get }
    var layoutMaxValueSource: any LayoutValueSource { get }
    var layoutLengthValueSource: any LayoutValueSource { get }
}

@MainActor
public protocol LayoutRegionSource {
    var layoutRegionPublisher: AnyPublisher<Region, Never> { get }
    var layoutHorizontalRangeSource: any LayoutRangeSource { get }
    var layoutVerticalRangeSource: any LayoutRangeSource { get }
}

@MainActor
public protocol LayoutValueTarget: AnyObject, Sendable {
    func setLayoutValue(_ value: Float)
}

@MainActor
public protocol LayoutPointTarget: AnyObject, Sendable {
    func setLayoutPoint(_ point: Point)
}

@MainActor
public protocol LayoutRangeTarget: AnyObject, Sendable {
    func setLayoutRange(_ range: Range)
}

@MainActor
public protocol LayoutRegionTarget: AnyObject, Sendable {
    func setLayoutRegion(_ region: Region)
}
