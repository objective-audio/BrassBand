import Foundation

@MainActor
public protocol LayoutLink {
    var layoutValueLinks: [LayoutValueLink] { get }
}

@MainActor
public struct LayoutValueLink {
    public let source: LayoutValueGuide
    public let destination: LayoutValueGuide

    init(source: LayoutValueGuide, destination: LayoutValueGuide) {
        self.source = source
        self.destination = destination
    }
}

extension LayoutValueLink: LayoutLink {
    public var layoutValueLinks: [LayoutValueLink] { [self] }
}

@MainActor
public struct LayoutPointLink {
    public let source: LayoutPointGuide
    public let destination: LayoutPointGuide

    public init(source: LayoutPointGuide, destination: LayoutPointGuide) {
        self.source = source
        self.destination = destination
    }
}

extension LayoutPointLink: LayoutLink {
    public var layoutValueLinks: [LayoutValueLink] {
        [
            .init(source: source.xGuide, destination: destination.xGuide),
            .init(source: source.yGuide, destination: destination.yGuide),
        ]
    }
}

@MainActor
public struct LayoutRangeLink {
    public let source: LayoutRangeGuide
    public let destination: LayoutRangeGuide

    public init(source: LayoutRangeGuide, destination: LayoutRangeGuide) {
        self.source = source
        self.destination = destination
    }
}

extension LayoutRangeLink: LayoutLink {
    public var layoutValueLinks: [LayoutValueLink] {
        [
            .init(source: source.minGuide, destination: destination.minGuide),
            .init(source: source.maxGuide, destination: destination.maxGuide),
        ]
    }
}

@MainActor
public struct LayoutRegionLink {
    public let source: LayoutRegionGuide
    public let destination: LayoutRegionGuide

    public init(source: LayoutRegionGuide, destination: LayoutRegionGuide) {
        self.source = source
        self.destination = destination
    }
}

extension LayoutRegionLink: LayoutLink {
    public var layoutValueLinks: [LayoutValueLink] {
        [
            .init(source: source.leftGuide, destination: destination.leftGuide),
            .init(source: source.rightGuide, destination: destination.rightGuide),
            .init(source: source.bottomGuide, destination: destination.bottomGuide),
            .init(source: source.topGuide, destination: destination.topGuide),
        ]
    }
}
