import Foundation

@MainActor
public enum Layout {
    // Value Source

    public static func constraint(
        _ source: some LayoutValueSource, _ target: some LayoutValueGuide,
        convert: @escaping @Sendable (Float) -> Float
    ) -> AnyCancellable {
        source.layoutValuePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutValue(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutValueSource, _ target: some LayoutPointGuide,
        convert: @escaping @Sendable (Float) -> Point
    ) -> AnyCancellable {
        source.layoutValuePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutPoint(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutValueSource, _ target: some LayoutRangeGuide,
        convert: @escaping @Sendable (Float) -> Range
    ) -> AnyCancellable {
        source.layoutValuePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRange(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutValueSource, _ target: some LayoutRegionGuide,
        convert: @escaping @Sendable (Float) -> Region
    ) -> AnyCancellable {
        source.layoutValuePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRegion(convert(value))
        }
    }

    // Point Source

    public static func constraint(
        _ source: some LayoutPointSource, _ target: some LayoutValueGuide,
        convert: @escaping @Sendable (Point) -> Float
    ) -> AnyCancellable {
        source.layoutPointPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutValue(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutPointSource, _ target: some LayoutPointGuide,
        convert: @escaping @Sendable (Point) -> Point
    ) -> AnyCancellable {
        source.layoutPointPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutPoint(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutPointSource, _ target: some LayoutRangeGuide,
        convert: @escaping @Sendable (Point) -> Range
    ) -> AnyCancellable {
        source.layoutPointPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRange(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutPointSource, _ target: some LayoutRegionGuide,
        convert: @escaping @Sendable (Point) -> Region
    ) -> AnyCancellable {
        source.layoutPointPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRegion(convert(value))
        }
    }

    // Range Source

    public static func constraint(
        _ source: some LayoutRangeSource, _ target: some LayoutValueGuide,
        convert: @escaping @Sendable (Range) -> Float
    ) -> AnyCancellable {
        source.layoutRangePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutValue(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutRangeSource, _ target: some LayoutPointGuide,
        convert: @escaping @Sendable (Range) -> Point
    ) -> AnyCancellable {
        source.layoutRangePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutPoint(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutRangeSource, _ target: some LayoutRangeGuide,
        convert: @escaping @Sendable (Range) -> Range
    ) -> AnyCancellable {
        source.layoutRangePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRange(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutRangeSource, _ target: some LayoutRegionGuide,
        convert: @escaping @Sendable (Range) -> Region
    ) -> AnyCancellable {
        source.layoutRangePublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRegion(convert(value))
        }
    }

    // Region Source

    public static func constraint(
        _ source: some LayoutRegionSource, _ target: some LayoutValueGuide,
        convert: @escaping @Sendable (Region) -> Float
    ) -> AnyCancellable {
        source.layoutRegionPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutValue(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutRegionSource, _ target: some LayoutPointGuide,
        convert: @escaping @Sendable (Region) -> Point
    ) -> AnyCancellable {
        source.layoutRegionPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutPoint(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutRegionSource, _ target: some LayoutRangeGuide,
        convert: @escaping @Sendable (Region) -> Range
    ) -> AnyCancellable {
        source.layoutRegionPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRange(convert(value))
        }
    }

    public static func constraint(
        _ source: some LayoutRegionSource, _ target: some LayoutRegionGuide,
        convert: @escaping @Sendable (Region) -> Region
    ) -> AnyCancellable {
        source.layoutRegionPublisher.sink { [weak target] value in
            guard let target else { return }
            target.setLayoutRegion(convert(value))
        }
    }
}
