import BrassBand
import Foundation

@MainActor
final class JustifiedPoints {
    private static let xPointCount: Int = 16
    private static let yPointCount: Int = 8
    private static let allPointCount: Int = xPointCount + yPointCount

    private static func makeLayoutGuides(count: Int) -> [LayoutValueGuide] {
        (0..<count).map { _ in LayoutValueGuide() }
    }

    private let rectPlane: RectPlane = .init(rectCount: allPointCount)
    private let xLayoutGuides: [LayoutValueGuide] = makeLayoutGuides(count: xPointCount)
    private let yLayoutGuides: [LayoutValueGuide] = makeLayoutGuides(count: yPointCount)

    private var cancellables: Set<AnyCancellable> = []

    init(layoutRegionSource: any LayoutRegionSource) {
        setupColors()
        setupLayoutGuides()

        let xReceivers: [Weak<LayoutValueGuide>] = xLayoutGuides.map(Weak.init)

        layoutRegionSource.layoutHorizontalRangeSource.layoutRangePublisher.sink { range in
            let justified = justify(
                begin: range.min, end: range.max,
                ratios: .init(repeating: 1.0, count: Self.xPointCount - 1))

            for (index, guide) in xReceivers.enumerated() {
                guard let guide = guide.value else { continue }
                guide.value = justified[index]
            }
        }.store(in: &cancellables)

        var yRatios: [Float] = []
        for index in 0..<(Self.yPointCount - 1) {
            if index < (Self.yPointCount / 2) {
                yRatios.append(powf(2.0, Float(index)))
            } else {
                yRatios.append(powf(2.0, Float(Self.yPointCount - 2 - index)))
            }
        }

        let yReceivers: [Weak<LayoutValueGuide>] = yLayoutGuides.map(Weak.init)

        layoutRegionSource.layoutVerticalRangeSource.layoutRangePublisher.sink { range in
            let justified = justify(
                begin: range.min, end: range.max,
                ratios: yRatios)

            for (index, guide) in yReceivers.enumerated() {
                guard let guide = guide.value else { continue }
                guide.value = justified[index]
            }
        }.store(in: &cancellables)
    }

    var node: Node { rectPlane.node }

    private func setupColors() {
        rectPlane.content.meshes.first?.isMeshColorUsed = true

        let rectPlaneData = rectPlane.data

        for index in 0..<Self.allPointCount {
            if index < Self.xPointCount {
                rectPlaneData.setRectColor(
                    .init(red: 1.0, green: 0.8, blue: 0.5, alpha: 1.0), rectIndex: index)
            } else {
                rectPlaneData.setRectColor(
                    .init(red: 0.8, green: 0.5, blue: 1.0, alpha: 1.0), rectIndex: index)
            }
        }
    }

    private func setupLayoutGuides() {
        for (index, layoutGuide) in xLayoutGuides.enumerated() {
            layoutGuide.valuePublisher.sink { [weak rectPlane] value in
                rectPlane?.data.setRectPosition(
                    .init(center: .init(x: value, y: 0.0), size: .init(repeating: 4.0)),
                    rectIndex: index)
            }.store(in: &cancellables)
        }
        for (index, layoutGuide) in yLayoutGuides.enumerated() {
            layoutGuide.valuePublisher.sink { [weak rectPlane] value in
                rectPlane?.data.setRectPosition(
                    .init(center: .init(x: 0.0, y: value), size: .init(repeating: 4.0)),
                    rectIndex: index + Self.xPointCount)
            }.store(in: &cancellables)
        }
    }
}
