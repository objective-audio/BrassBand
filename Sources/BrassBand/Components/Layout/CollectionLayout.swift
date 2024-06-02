import Foundation

public struct CollectionCellSize: Equatable, Sendable {
    public enum Column: Equatable, Sendable {
        case fixed(Float)
        case filled

        func value(orFilled filled: Float) -> Float {
            switch self {
            case .fixed(let value):
                return value
            case .filled:
                return filled
            }
        }
    }

    public var column: Column
    public var row: Float

    public init(column: Column, row: Float) {
        self.column = column
        self.row = row
    }

    public init() {
        self.column = .fixed(0.0)
        self.row = 0.0
    }

    public static let zero: Self = .init()
    public static let one: Self = .init(column: .fixed(1.0), row: 1.0)
}

private struct CollectionLayoutSize: Equatable, Sendable {
    var size: Size
    var column: Float {
        get { size.width }
        set { size.width = newValue }
    }
    var row: Float {
        get { size.height }
        set { size.height = newValue }
    }

    init() {
        size = .zero
    }

    init(_ cellSize: CollectionCellSize, filled: Float) {
        size = .init(width: cellSize.column.value(orFilled: filled), height: cellSize.row)
    }

    init(column: Float, row: Float) {
        size = .init(width: column, height: row)
    }

    init(_ size: Size) {
        self.size = size
    }

    static let zero: Self = .init()
}

extension CollectionLayoutSize: CustomStringConvertible {
    public var description: String {
        "{column:\(column),row:\(row)}"
    }
}

private struct CollectionLayoutRegion: Sendable {
    var region: Region
    var offset: Point {
        region.origin
    }
    var size: CollectionLayoutSize {
        .init(region.size)
    }

    func combined(_ other: CollectionLayoutRegion) -> CollectionLayoutRegion {
        .init(self.region.combined(other.region))
    }

    init(offset: Point, size: CollectionLayoutSize) {
        region = .init(origin: offset, size: size.size)
    }

    init(_ region: Region) {
        self.region = region
    }
}

extension CollectionLayoutRegion: CustomStringConvertible {
    public var description: String {
        "{offset:\(offset),size:\(size)}"
    }
}

@MainActor
public final class CollectionLayout {
    public typealias CellSize = CollectionCellSize
    private typealias LayoutSize = CollectionLayoutSize
    private typealias LayoutRegion = CollectionLayoutRegion

    public struct Line: Equatable {
        public let cellSizes: [CellSize]
        public let newLineMinOffset: Float

        public init(cellSizes: [CellSize], newLineMinOffset: Float = 0.0) {
            self.cellSizes = cellSizes
            self.newLineMinOffset = newLineMinOffset
        }
    }

    private struct CellLocation {
        let lineIndex: Int
        let cellIndex: Int
    }

    public let borders: LayoutBorders

    public let preferredLayoutGuide: LayoutRegionGuide
    public var preferredFrame: Region {
        get { preferredLayoutGuide.region }
        set { preferredLayoutGuide.region = newValue }
    }

    public var preferredCellCount: Int {
        didSet { updateLayout() }
    }
    public var defaultCellSize: CellSize {
        didSet { updateLayout() }
    }
    public var lines: [Line] {
        didSet { updateLayout() }
    }
    public var rowSpacing: Float {
        didSet { updateLayout() }
    }
    public var colSpacing: Float {
        didSet { updateLayout() }
    }
    public var alignment: LayoutAlignment {
        didSet { updateLayout() }
    }
    public var direction: LayoutDirection {
        didSet { updateLayout() }
    }
    public var rowOrder: LayoutOrder {
        didSet { updateLayout() }
    }
    public var columnOrder: LayoutOrder {
        didSet { updateLayout() }
    }

    @CurrentValue public private(set) var actualCellRegions: [Region] = []
    public var actualCellRegionsPublisher: AnyPublisher<[Region], Never> {
        $actualCellRegions.eraseToAnyPublisher()
    }
    public var actualCellCount: Int { actualCellRegions.count }

    private let actualFrameLayoutGuide: LayoutRegionGuide = .init()
    public var actualFrame: Region { actualFrameLayoutGuide.region }
    public var actualFrameLayoutSource: some LayoutRegionSource { actualFrameLayoutGuide }

    private let borderLayoutGuide: LayoutRegionGuide = .init()

    private var cancellables: Set<AnyCancellable> = []

    public init(
        frame: Region = .zero, preferredCellCount: Int = 0,
        defaultCellSize: CellSize = .one,  // oneではなくてzeroにしたい？
        lines: [Line] = [], rowSpacing: Float = 0.0, colSpacing: Float = 0.0,
        borders: LayoutBorders = .zero, alignment: LayoutAlignment = .min,
        direction: LayoutDirection = .vertical, rowOrder: LayoutOrder = .ascending,
        colOrder: LayoutOrder = .ascending
    ) {
        preferredLayoutGuide = .init(frame)
        self.preferredCellCount = preferredCellCount
        self.defaultCellSize = defaultCellSize
        self.lines = lines
        self.rowSpacing = rowSpacing
        self.colSpacing = colSpacing
        self.borders = borders
        self.alignment = alignment
        self.direction = direction
        self.rowOrder = rowOrder
        self.columnOrder = colOrder

        assert(borders.left >= 0 && borders.right >= 0 && borders.bottom >= 0 && borders.top >= 0)

        preferredLayoutGuide.leftGuide.valuePublisher.sink { [weak self] value in
            self?.borderLayoutGuide.leftGuide.value = value + borders.left
        }.store(in: &cancellables)

        preferredLayoutGuide.rightGuide.valuePublisher.sink { [weak self] value in
            self?.borderLayoutGuide.rightGuide.value = value - borders.right
        }.store(in: &cancellables)

        preferredLayoutGuide.bottomGuide.valuePublisher.sink { [weak self] value in
            self?.borderLayoutGuide.bottomGuide.value = value + borders.bottom
        }.store(in: &cancellables)

        preferredLayoutGuide.topGuide.valuePublisher.sink { [weak self] value in
            self?.borderLayoutGuide.topGuide.value = value - borders.top
        }.store(in: &cancellables)

        preferredLayoutGuide.regionPublisher.sink { [weak self] _ in
            self?.updateLayout()
        }.store(in: &cancellables)

        borderLayoutGuide.regionPublisher.sink { [weak self] _ in
            self?.updateLayout()
        }.store(in: &cancellables)

        updateLayout()
    }

    private func updateLayout() {
        let frameLayouSize = direction.collectionLayoutSize(size: preferredLayoutGuide.region.size)
        let isColumnLimiting = frameLayouSize.column != 0
        let isRowLimiting = frameLayouSize.row != 0
        let borderLayoutSize = direction.collectionLayoutSize(size: borderLayoutGuide.region.size)

        var actualCellCount: Int = 0
        var actualCellRegions: [LayoutRegion] = []

        if preferredCellCount > 0 {
            var regions: [[LayoutRegion]] = []
            var rowMaxDiff: Float = 0.0
            var origin: Point = .zero
            var rowRegions: [LayoutRegion] = []

            for index in 0..<preferredCellCount {
                let cellSize = cellLayoutSize(at: index, borderLayoutSize: borderLayoutSize)

                // 列の幅が制限された範囲を超えているか
                let isColumnOver =
                    isColumnLimiting && (borderLayoutSize.column < (origin.x + cellSize.column))

                // 列の幅が制限された範囲を超えていて、まだ1つもCellがなければ、表示できないので中断する
                if isColumnOver && rowRegions.isEmpty {
                    break
                }

                // 列の幅が制限された範囲を超えているか、改行後の行始めなら、次の行に移る
                if isColumnOver || isHeadOfNewLine(at: index) {
                    regions.append(rowRegions)

                    let rowNewLineDiff = rowNewLineDiff(at: index)
                    if rowNewLineDiff > rowMaxDiff {
                        rowMaxDiff = rowNewLineDiff
                    }

                    origin.x = 0.0
                    origin.y += rowMaxDiff

                    rowRegions.removeAll()
                    rowMaxDiff = 0.0
                }

                // 行の幅が制限された範囲を超えていたら、表示できないので中断する
                if isRowLimiting && origin.y + cellSize.row > borderLayoutSize.row {
                    break
                }

                rowRegions.append(LayoutRegion(offset: origin, size: cellSize))

                actualCellCount += 1

                let rowCellDiff = rowCellDiff(at: index)
                if rowCellDiff > rowMaxDiff {
                    rowMaxDiff = rowCellDiff
                }

                origin.x += colDiff(at: index, borderLayoutSize: borderLayoutSize)
            }

            if !rowRegions.isEmpty {
                regions.append(rowRegions)
            }

            actualCellRegions = aligned(regions: regions, borderLayoutSize: borderLayoutSize)
        }

        let (actualFrame, cellRegions) = transformed(
            cellLayoutRegions: actualCellRegions, borderLayoutSize: borderLayoutSize,
            frameOrigin: borderLayoutGuide.region.origin)

        self.actualCellRegions = cellRegions
        self.actualFrameLayoutGuide.region = actualFrame
    }

    private func aligned(
        regions: [[LayoutRegion]], borderLayoutSize: CollectionLayoutSize
    ) -> [LayoutRegion] {
        return regions.map { rowRegions in
            guard let firstRowRegion = rowRegions.first,
                let lastRowRegion = rowRegions.last
            else {
                return [LayoutRegion]()
            }

            let alignOffset: Float = {
                switch alignment {
                case .min:
                    return 0.0
                case .mid, .max:
                    let contentWidth =
                        lastRowRegion.offset.x + lastRowRegion.size.column - firstRowRegion.offset.x
                    return (borderLayoutSize.column - contentWidth) * alignment.rate
                }
            }()

            return rowRegions.map {
                LayoutRegion(
                    offset: $0.offset + .init(x: alignOffset, y: 0.0),
                    size: $0.size)
            }
        }.flatMap(\.self)
    }

    private func emptyLayoutRegion(borderLayoutSize: CollectionLayoutSize) -> LayoutRegion {
        aligned(regions: [[.init(offset: .zero, size: .zero)]], borderLayoutSize: borderLayoutSize)
            .first!
    }

    private func ordered(
        cellLayoutRegions: [LayoutRegion],
        borderLayoutSize: LayoutSize
    ) -> [LayoutRegion] {
        cellLayoutRegions.map {
            switch columnOrder {
            case .ascending:
                return $0
            case .descending:
                // 横の位置を逆にする
                let left = borderLayoutSize.column - $0.region.right
                return LayoutRegion(offset: .init(x: left, y: $0.offset.y), size: $0.size)
            }
        }.map {
            switch rowOrder {
            case .ascending:
                return $0
            case .descending:
                // 縦の位置を逆にする
                let bottom = borderLayoutSize.row - $0.region.top
                return LayoutRegion(
                    offset: .init(x: $0.offset.x, y: bottom), size: $0.size)
            }
        }
    }

    private func transformed(
        cellLayoutRegions: [LayoutRegion], borderLayoutSize: LayoutSize,
        frameOrigin: Point
    ) -> (
        Region, [Region]
    ) {
        let emptyLayoutRegion = ordered(
            cellLayoutRegions: [emptyLayoutRegion(borderLayoutSize: borderLayoutSize)],
            borderLayoutSize: borderLayoutSize
        ).first!
        let alignedLayoutRegions = ordered(
            cellLayoutRegions: cellLayoutRegions, borderLayoutSize: borderLayoutSize)
        let layoutFrame = alignedLayoutRegions.reduce(
            into: emptyLayoutRegion
        ) { partialResult, layoutRegion in
            partialResult = .init(partialResult.region.combined(layoutRegion.region))
        }

        // 縦と横を入れ替え、originの位置にずらす
        let swappedRegions = alignedLayoutRegions.map {
            switch direction {
            case .vertical:
                return $0.region + frameOrigin
            case .horizontal:
                return Region(
                    origin: .init(x: $0.offset.y, y: $0.offset.x) + frameOrigin,
                    size: .init(width: $0.size.row, height: $0.size.column))
            }
        }

        let swappedFrame: Region =
            {
                switch direction {
                case .vertical:
                    return layoutFrame.region
                case .horizontal:
                    return Region(
                        origin: .init(x: layoutFrame.offset.y, y: layoutFrame.offset.x),
                        size: .init(width: layoutFrame.size.row, height: layoutFrame.size.column))
                }
            }() + frameOrigin

        return (swappedFrame, swappedRegions)
    }

    private func cellLocation(at cellIndex: Int) -> CellLocation? {
        var firstIndex = 0
        var lineIndex = 0

        for line in lines {
            if firstIndex <= cellIndex && cellIndex < (firstIndex + line.cellSizes.count) {
                return .init(lineIndex: lineIndex, cellIndex: cellIndex - firstIndex)
            }
            firstIndex += line.cellSizes.count
            lineIndex += 1
        }

        return nil
    }

    private func cellLayoutSize(at index: Int, borderLayoutSize: LayoutSize) -> LayoutSize {
        .init(cellSize(at: index), filled: borderLayoutSize.column)
    }

    private func cellSize(at index: Int) -> CellSize {
        var findIndex = 0

        for line in lines {
            let lineIndex = index - findIndex
            let lineCellCount = line.cellSizes.count

            if lineIndex < lineCellCount {
                return line.cellSizes[lineIndex]
            }

            findIndex += lineCellCount
        }

        return defaultCellSize
    }

    private func isHeadOfNewLine(at index: Int) -> Bool {
        guard let cellLocation = cellLocation(at: index) else { return false }
        return cellLocation.lineIndex > 0 && cellLocation.cellIndex == 0
    }

    private func colDiff(at index: Int, borderLayoutSize: LayoutSize) -> Float {
        cellSize(at: index).column.value(orFilled: borderLayoutSize.column) + colSpacing
    }

    private func rowCellDiff(at index: Int) -> Float {
        cellSize(at: index).row + rowSpacing
    }

    private func rowNewLineDiff(at index: Int) -> Float {
        var diff: Float = 0.0

        if let cellLocation = cellLocation(at: index) {
            var lineIndex = cellLocation.lineIndex

            while lineIndex > 0 {
                lineIndex -= 1

                diff += lines[lineIndex].newLineMinOffset + rowSpacing

                if lines[lineIndex].cellSizes.count > 0 {
                    break
                }
            }
        }

        return diff
    }
}

extension LayoutAlignment {
    fileprivate var rate: Float {
        switch self {
        case .min:
            return 0.0
        case .mid:
            return 0.5
        case .max:
            return 1.0
        }
    }
}

extension LayoutDirection {
    fileprivate func collectionLayoutSize(size: Size) -> CollectionLayoutSize {
        if self == .horizontal {
            return .init(column: size.height, row: size.width)
        } else {
            return .init(size)
        }
    }
}
