import Testing

@testable import BrassBand

@MainActor
struct LayoutConstraintTests {
    @Test func constraintValueToValue() {
        let source = LayoutValueGuide()
        source.value = 0.0
        let destination = LayoutValueGuide()
        destination.value = -1.0

        #expect(destination.value == -1.0)

        let cancellable = Layout.constraint(source, destination, convert: { $0 })

        #expect(destination.value == 0.0)

        source.value = 1.0

        #expect(destination.value == 1.0)

        cancellable.cancel()
    }

    @Test func constraintValueToPoint() {
        let source = LayoutValueGuide()
        source.value = 0.0
        let destination = LayoutPointGuide()
        destination.point = .init(repeating: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(x: $0, y: $0 * 2.0)
            })

        #expect(destination.point == .zero)

        source.value = 2.0

        #expect(destination.point == .init(x: 2.0, y: 4.0))

        cancellable.cancel()
    }

    @Test func constraintValueToRange() {
        let source = LayoutValueGuide()
        source.value = 0.0
        let destination = LayoutRangeGuide()
        destination.range = .init(location: -1.0, length: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(location: $0, length: $0 * 2.0)
            })

        #expect(destination.range == .zero)

        source.value = 2.0

        #expect(destination.range == .init(location: 2.0, length: 4.0))

        cancellable.cancel()
    }

    @Test func constraintValueToRegion() {
        let source = LayoutValueGuide()
        source.value = 0.0
        let destination = LayoutRegionGuide()
        destination.region = .init(origin: .init(repeating: -1.0), size: .init(repeating: -1.0))

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(
                    origin: .init(x: $0, y: $0 * 2.0),
                    size: .init(width: $0 * 4.0, height: $0 * 8.0))
            })

        #expect(destination.region == .zero)

        source.value = 2.0

        #expect(
            destination.region
                == .init(origin: .init(x: 2.0, y: 4.0), size: .init(width: 8.0, height: 16.0)))

        cancellable.cancel()
    }

    @Test func constraintPointToValue() {
        let source = LayoutPointGuide()
        source.point = .zero
        let destination = LayoutValueGuide()
        destination.value = -1.0

        #expect(destination.value == -1.0)

        let cancellable = Layout.constraint(source, destination, convert: { $0.x })

        #expect(destination.value == 0.0)

        source.point = .init(x: 1.0, y: 2.0)

        #expect(destination.value == 1.0)

        cancellable.cancel()
    }

    @Test func constraintPointToPoint() {
        let source = LayoutPointGuide()
        source.point = .zero
        let destination = LayoutPointGuide()
        destination.point = .init(repeating: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(x: $0.x, y: $0.y * 2.0)
            })

        #expect(destination.point == .zero)

        source.point = .init(x: 2.0, y: 3.0)

        #expect(destination.point == .init(x: 2.0, y: 6.0))

        cancellable.cancel()
    }

    @Test func constraintPointToRange() {
        let source = LayoutPointGuide()
        source.point = .zero
        let destination = LayoutRangeGuide()
        destination.range = .init(location: -1.0, length: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(location: $0.x, length: $0.y * 2.0)
            })

        #expect(destination.range == .zero)

        source.point = .init(x: 2.0, y: 3.0)

        #expect(destination.range == .init(location: 2.0, length: 6.0))

        cancellable.cancel()
    }

    @Test func constraintPointToRegion() {
        let source = LayoutPointGuide()
        source.point = .zero
        let destination = LayoutRegionGuide()
        destination.region = .init(origin: .init(repeating: -1.0), size: .init(repeating: -1.0))

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(
                    origin: .init(x: $0.x, y: $0.y * 2.0),
                    size: .init(width: $0.x * 4.0, height: $0.y * 8.0))
            })

        #expect(destination.region == .zero)

        source.point = .init(x: 2.0, y: 3.0)

        #expect(
            destination.region
                == .init(origin: .init(x: 2.0, y: 6.0), size: .init(width: 8.0, height: 24.0)))

        cancellable.cancel()
    }

    @Test func constraintRangeToValue() {
        let source = LayoutRangeGuide()
        source.range = .zero
        let destination = LayoutValueGuide()
        destination.value = -1.0

        #expect(destination.value == -1.0)

        let cancellable = Layout.constraint(source, destination, convert: { $0.location })

        #expect(destination.value == 0.0)

        source.range = .init(location: 1.0, length: 2.0)

        #expect(destination.value == 1.0)

        cancellable.cancel()
    }

    @Test func constraintRangeToPoint() {
        let source = LayoutRangeGuide()
        source.range = .zero
        let destination = LayoutPointGuide()
        destination.point = .init(repeating: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(x: $0.location, y: $0.length * 2.0)
            })

        #expect(destination.point == .zero)

        source.range = .init(location: 2.0, length: 3.0)

        #expect(destination.point == .init(x: 2.0, y: 6.0))

        cancellable.cancel()
    }

    @Test func constraintRangeToRange() {
        let source = LayoutRangeGuide()
        source.range = .zero
        let destination = LayoutRangeGuide()
        destination.range = .init(location: -1.0, length: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(location: $0.location, length: $0.length * 2.0)
            })

        #expect(destination.range == .zero)

        source.range = .init(location: 2.0, length: 3.0)

        #expect(destination.range == .init(location: 2.0, length: 6.0))

        cancellable.cancel()
    }

    @Test func constraintRangeToRegion() {
        let source = LayoutRangeGuide()
        source.range = .zero
        let destination = LayoutRegionGuide()
        destination.region = .init(origin: .init(repeating: -1.0), size: .init(repeating: -1.0))

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(
                    origin: .init(x: $0.location, y: $0.length * 2.0),
                    size: .init(width: $0.location * 4.0, height: $0.length * 8.0))
            })

        #expect(destination.region == .zero)

        source.range = .init(location: 2.0, length: 3.0)

        #expect(
            destination.region
                == .init(origin: .init(x: 2.0, y: 6.0), size: .init(width: 8.0, height: 24.0)))

        cancellable.cancel()
    }

    @Test func constraintRegionToValue() {
        let source = LayoutRegionGuide()
        source.region = .zero
        let destination = LayoutValueGuide()
        destination.value = -1.0

        #expect(destination.value == -1.0)

        let cancellable = Layout.constraint(source, destination, convert: { $0.origin.x })

        #expect(destination.value == 0.0)

        source.region = .init(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0))

        #expect(destination.value == 1.0)

        cancellable.cancel()
    }

    @Test func constraintRegionToPoint() {
        let source = LayoutRegionGuide()
        source.region = .zero
        let destination = LayoutPointGuide()
        destination.point = .init(repeating: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(x: $0.origin.x, y: $0.origin.y * 2.0)
            })

        #expect(destination.point == .zero)

        source.region = .init(origin: .init(x: 2.0, y: 3.0), size: .init(width: 4.0, height: 5.0))

        #expect(destination.point == .init(x: 2.0, y: 6.0))

        cancellable.cancel()
    }

    @Test func constraintRegionToRange() {
        let source = LayoutRegionGuide()
        source.region = .zero
        let destination = LayoutRangeGuide()
        destination.range = .init(location: -1.0, length: -1.0)

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(location: $0.origin.x, length: $0.origin.y * 2.0)
            })

        #expect(destination.range == .zero)

        source.region = .init(origin: .init(x: 2.0, y: 3.0), size: .init(width: 4.0, height: 5.0))

        #expect(destination.range == .init(location: 2.0, length: 6.0))

        cancellable.cancel()
    }

    @Test func constraintRegionToRegion() {
        let source = LayoutRegionGuide()
        source.region = .zero
        let destination = LayoutRegionGuide()
        destination.region = .init(origin: .init(repeating: -1.0), size: .init(repeating: -1.0))

        let cancellable = Layout.constraint(
            source, destination,
            convert: {
                .init(
                    origin: .init(x: $0.origin.x, y: $0.origin.y * 2.0),
                    size: .init(width: $0.size.width * 4.0, height: $0.size.height * 8.0))
            })

        #expect(destination.region == .zero)

        source.region = .init(origin: .init(x: 2.0, y: 3.0), size: .init(width: 4.0, height: 5.0))

        #expect(
            destination.region
                == .init(origin: .init(x: 2.0, y: 6.0), size: .init(width: 16.0, height: 40.0)))

        cancellable.cancel()
    }
}
