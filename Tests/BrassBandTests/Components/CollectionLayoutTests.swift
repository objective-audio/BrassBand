import Testing

@testable import BrassBand

@MainActor
struct CollectionLayoutTests {
    @Test func initial() {
        let layout = CollectionLayout()

        #expect(layout.preferredFrame == .zero)
        #expect(layout.preferredCellCount == 0)
        #expect(layout.defaultCellSize == .init(.one))
        #expect(layout.lines.count == 0)
        #expect(layout.rowSpacing == 0.0)
        #expect(layout.colSpacing == 0.0)
        #expect(layout.borders == .zero)
        #expect(layout.alignment == .min)
        #expect(layout.direction == .vertical)
        #expect(layout.rowOrder == .ascending)
        #expect(layout.columnOrder == .ascending)
        #expect(layout.actualCellCount == 0)
        #expect(layout.actualFrame == .zero)
    }

    @Test func initWithParams() {
        let layout = CollectionLayout(
            frame: .init(origin: .init(x: 11.0, y: 12.0), size: .init(width: 13.0, height: 14.0)),
            preferredCellCount: 10,
            defaultCellSize: .init(column: .fixed(3.5), row: 2.5),
            lines: [
                .init(
                    cellSizes: [
                        .init(column: .fixed(3.6), row: 2.6), .init(column: .fixed(3.7), row: 2.7),
                    ],
                    newLineMinOffset: 3.9)
            ],
            rowSpacing: 4.0,
            colSpacing: 4.0,
            borders: .init(top: 7.5, bottom: 6.5, left: 5.0, right: 6.0),
            alignment: .max,
            direction: .horizontal,
            rowOrder: .descending,
            colOrder: .descending)

        #expect(
            layout.preferredFrame
                == Region(origin: .init(x: 11.0, y: 12.0), size: .init(width: 13.0, height: 14.0)))
        #expect(layout.preferredCellCount == 10)
        #expect(layout.defaultCellSize == .init(column: .fixed(3.5), row: 2.5))
        #expect(layout.lines.count == 1)
        #expect(layout.lines[0].cellSizes.count == 2)
        #expect(layout.lines[0].cellSizes[0] == .init(column: .fixed(3.6), row: 2.6))
        #expect(layout.lines[0].cellSizes[1] == .init(column: .fixed(3.7), row: 2.7))
        #expect(layout.lines[0].newLineMinOffset == 3.9)
        #expect(layout.rowSpacing == 4.0)
        #expect(layout.colSpacing == 4.0)
        #expect(layout.borders == .init(top: 7.5, bottom: 6.5, left: 5.0, right: 6.0))
        #expect(layout.alignment == .max)
        #expect(layout.direction == .horizontal)
        #expect(layout.rowOrder == .descending)
        #expect(layout.columnOrder == .descending)
        #expect(layout.actualCellCount == 0)
        #expect(layout.actualFrame == Region(origin: .init(x: 18.0, y: 18.5), size: .zero))
    }

    @Test func actualCellRegions() {
        let layout =
            CollectionLayout(
                frame: .init(origin: .init(x: 2.0, y: 4.0), size: .init(width: 8.0, height: 9.0)),
                preferredCellCount: 4,
                defaultCellSize: .init(column: .fixed(2.0), row: 3.0),
                rowSpacing: 1.0,
                colSpacing: 1.0,
                borders: .init(top: 1.0, bottom: 1.0, left: 1.0, right: 1.0))

        let regions = layout.actualCellRegions

        #expect(regions.count == 4)

        #expect(regions[0].left == 3.0)
        #expect(regions[0].right == 5.0)
        #expect(regions[0].bottom == 5.0)
        #expect(regions[0].top == 8.0)

        #expect(regions[1].left == 6.0)
        #expect(regions[1].right == 8.0)
        #expect(regions[1].bottom == 5.0)
        #expect(regions[1].top == 8.0)

        #expect(regions[2].left == 3.0)
        #expect(regions[2].right == 5.0)
        #expect(regions[2].bottom == 9.0)
        #expect(regions[2].top == 12.0)

        #expect(regions[3].left == 6.0)
        #expect(regions[3].right == 8.0)
        #expect(regions[3].bottom == 9.0)
        #expect(regions[3].top == 12.0)
    }

    @Test func actualCellCount() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(repeating: 2.0)),
            preferredCellCount: 1)

        #expect(layout.actualCellCount == 1)

        layout.preferredCellCount = 5

        #expect(layout.actualCellCount == 4)

        layout.preferredCellCount = 2

        #expect(layout.actualCellCount == 2)
    }

    @Test func actualFrame() {
        let layout = CollectionLayout(
            frame: .init(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 2.0)),
            preferredCellCount: 1)

        #expect(layout.actualFrame == Region(origin: .init(x: 1.0, y: 2.0), size: .one))

        layout.preferredCellCount = 2

        #expect(
            layout.actualFrame
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))

        layout.preferredCellCount = 3

        #expect(
            layout.actualFrame
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 2.0)))

        layout.preferredCellCount = 4

        #expect(
            layout.actualFrame
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 2.0)))
    }

    @Test(arguments: [
        (
            LayoutAlignment.min, LayoutDirection.vertical, LayoutOrder.ascending,
            LayoutOrder.ascending, Point(x: 2.0, y: 3.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.vertical, LayoutOrder.ascending,
            LayoutOrder.descending, Point(x: 2.0, y: 5.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.vertical, LayoutOrder.descending,
            LayoutOrder.ascending, Point(x: 3.0, y: 3.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.vertical, LayoutOrder.descending,
            LayoutOrder.descending, Point(x: 3.0, y: 5.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.vertical, LayoutOrder.ascending,
            LayoutOrder.ascending, Point(x: 2.5, y: 3.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.vertical, LayoutOrder.ascending,
            LayoutOrder.descending, Point(x: 2.5, y: 5.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.vertical, LayoutOrder.descending,
            LayoutOrder.ascending, Point(x: 2.5, y: 3.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.vertical, LayoutOrder.descending,
            LayoutOrder.descending, Point(x: 2.5, y: 5.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.vertical, LayoutOrder.ascending,
            LayoutOrder.ascending, Point(x: 3.0, y: 3.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.vertical, LayoutOrder.ascending,
            LayoutOrder.descending, Point(x: 3.0, y: 5.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.vertical, LayoutOrder.descending,
            LayoutOrder.ascending, Point(x: 2.0, y: 3.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.vertical, LayoutOrder.descending,
            LayoutOrder.descending, Point(x: 2.0, y: 5.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.horizontal, LayoutOrder.ascending,
            LayoutOrder.ascending, Point(x: 2.0, y: 3.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.horizontal, LayoutOrder.ascending,
            LayoutOrder.descending, Point(x: 3.0, y: 3.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.horizontal, LayoutOrder.descending,
            LayoutOrder.ascending, Point(x: 2.0, y: 5.0)
        ),
        (
            LayoutAlignment.min, LayoutDirection.horizontal, LayoutOrder.descending,
            LayoutOrder.descending, Point(x: 3.0, y: 5.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.horizontal, LayoutOrder.ascending,
            LayoutOrder.ascending, Point(x: 2.0, y: 4.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.horizontal, LayoutOrder.ascending,
            LayoutOrder.descending, Point(x: 3.0, y: 4.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.horizontal, LayoutOrder.descending,
            LayoutOrder.ascending, Point(x: 2.0, y: 4.0)
        ),
        (
            LayoutAlignment.mid, LayoutDirection.horizontal, LayoutOrder.descending,
            LayoutOrder.descending, Point(x: 3.0, y: 4.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.horizontal, LayoutOrder.ascending,
            LayoutOrder.ascending, Point(x: 2.0, y: 5.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.horizontal, LayoutOrder.ascending,
            LayoutOrder.descending, Point(x: 3.0, y: 5.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.horizontal, LayoutOrder.descending,
            LayoutOrder.ascending, Point(x: 2.0, y: 3.0)
        ),
        (
            LayoutAlignment.max, LayoutDirection.horizontal, LayoutOrder.descending,
            LayoutOrder.descending, Point(x: 3.0, y: 3.0)
        ),
    ]) func actualFrameCountZero(
        alignment: LayoutAlignment, direction: LayoutDirection, colOrder: LayoutOrder,
        rowOrder: LayoutOrder, expected: Point
    ) {
        let layout = CollectionLayout(
            frame: .init(origin: .init(x: 1.0, y: 2.0), size: .init(width: 3.0, height: 4.0)),
            preferredCellCount: 0, borders: .init(top: 1.0, bottom: 1.0, left: 1.0, right: 1.0))

        layout.alignment = alignment
        layout.direction = direction
        layout.columnOrder = colOrder
        layout.rowOrder = rowOrder

        #expect(layout.actualFrame == Region(origin: expected, size: .zero))
    }

    @Test func observeActualCellRegions() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(repeating: 2.0)), preferredCellCount: 1)

        var notified: [[Region]] = []

        let canceller = layout.actualCellRegionsPublisher.sink { regions in
            notified.append(regions)
        }

        layout.preferredCellCount = 5

        #expect(notified.count == 2)
        #expect(notified[1].count == 4)

        layout.preferredCellCount = 2

        #expect(notified.count == 3)
        #expect(notified[2].count == 2)

        canceller.cancel()
    }

    @Test func setPreferredFrame() {
        let layout =
            CollectionLayout(
                frame: .init(origin: .init(x: 2.0, y: 4.0), size: .init(width: 8.0, height: 16.0)),
                preferredCellCount: 4,
                defaultCellSize: .init(column: .fixed(2.0), row: 3.0),
                rowSpacing: 1.0,
                colSpacing: 1.0,
                borders: .init(top: 1.0, bottom: 1.0, left: 1.0, right: 1.0))

        #expect(
            layout.preferredFrame
                == Region(origin: .init(x: 2.0, y: 4.0), size: .init(width: 8.0, height: 16.0)))

        layout.preferredFrame = Region(
            origin: .init(x: 3.0, y: 5.0), size: .init(width: 7.0, height: 16.0))

        #expect(
            layout.preferredFrame
                == Region(origin: .init(x: 3.0, y: 5.0), size: .init(width: 7.0, height: 16.0)))

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions[0].left == 4.0)
        #expect(cellRegions[0].right == 6.0)
        #expect(cellRegions[0].bottom == 6.0)
        #expect(cellRegions[0].top == 9.0)

        #expect(cellRegions[1].left == 7.0)
        #expect(cellRegions[1].right == 9.0)
        #expect(cellRegions[1].bottom == 6.0)
        #expect(cellRegions[1].top == 9.0)

        #expect(cellRegions[2].left == 4.0)
        #expect(cellRegions[2].right == 6.0)
        #expect(cellRegions[2].bottom == 10.0)
        #expect(cellRegions[2].top == 13.0)

        #expect(cellRegions[3].left == 7.0)
        #expect(cellRegions[3].right == 9.0)
        #expect(cellRegions[3].bottom == 10.0)
        #expect(cellRegions[3].top == 13.0)
    }

    @Test func limitingRow() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 1.0, height: 0.0)),
            preferredCellCount: 8,
            defaultCellSize: .one,
            direction: .vertical)

        // フレームの高さが0ならセルを作る範囲の制限をかけない
        #expect(layout.actualCellCount == 8)

        layout.preferredFrame = .init(origin: .zero, size: .init(width: 0.0, height: 0.5))

        // フレームの高さが0より大きくてセルの高さよりも低い場合は作れるセルがない
        #expect(layout.actualCellCount == 0)

        // セルの並びを横にして縦横の制限が入れ替わる

        layout.direction = .horizontal
        layout.preferredFrame = .init(origin: .zero, size: .init(width: 0.0, height: 1.0))

        // フレームの幅が0ならセルを作る範囲の制限をかけない
        #expect(layout.actualCellCount == 8)

        layout.preferredFrame = .init(origin: .zero, size: .init(width: 0.5, height: 0.0))

        // フレームの幅が0より大きくてセルの幅よりも狭い場合は作れるセルがない
        #expect(layout.actualCellCount == 0)
    }

    @Test func limitingColumn() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 0.0, height: 1.0)),
            preferredCellCount: 8,
            defaultCellSize: .one,
            direction: .horizontal)

        // フレームの幅が0ならセルを作る範囲の制限をかけない
        #expect(layout.actualCellCount == 8)

        layout.preferredFrame = .init(origin: .zero, size: .init(width: 0.5, height: 0.0))

        // フレームの幅が0より大きくてセルの幅よりも狭い場合は作れるセルがない
        #expect(layout.actualCellCount == 0)

        // セルの並びを縦にして縦横の制限が入れ替わる

        layout.direction = .vertical
        layout.preferredFrame = .init(origin: .zero, size: .init(width: 1.0, height: 0.0))

        // フレームの高さが0ならセルを作る範囲の制限をかけない
        #expect(layout.actualCellCount == 8)

        layout.preferredFrame = .init(origin: .zero, size: .init(width: 0.0, height: 0.5))

        // フレームの高さが0より大きくてセルの高さよりも低い場合は作れるセルがない
        #expect(layout.actualCellCount == 0)
    }

    @Test func setPreferredCellCount() {
        let layout = CollectionLayout(preferredCellCount: 2)

        #expect(layout.preferredCellCount == 2)

        layout.preferredCellCount = 3

        #expect(layout.preferredCellCount == 3)

        layout.preferredCellCount = 0

        #expect(layout.preferredCellCount == 0)
    }

    @Test func setDefaultCellSize() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 2.0, height: 0.0)), preferredCellCount: 3
        )

        #expect(layout.defaultCellSize == .init(.one))

        do {
            let cellRegions = layout.actualCellRegions
            #expect(cellRegions[0].left == 0.0)
            #expect(cellRegions[0].bottom == 0.0)
            #expect(cellRegions[1].left == 1.0)
            #expect(cellRegions[1].bottom == 0.0)
            #expect(cellRegions[2].left == 0.0)
            #expect(cellRegions[2].bottom == 1.0)
        }

        layout.defaultCellSize = .init(column: .fixed(2.0), row: 3.0)

        #expect(layout.defaultCellSize == .init(column: .fixed(2.0), row: 3.0))

        do {
            let cellRegions = layout.actualCellRegions
            #expect(cellRegions[0].left == 0.0)
            #expect(cellRegions[0].bottom == 0.0)
            #expect(cellRegions[1].left == 0.0)
            #expect(cellRegions[1].bottom == 3.0)
            #expect(cellRegions[2].left == 0.0)
            #expect(cellRegions[2].bottom == 6.0)
        }
    }

    @Test func newLineByFrameOnly() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 3.0, height: 0.0)), preferredCellCount: 5
        )

        #expect(layout.lines.count == 0)

        layout.lines = [
            .init(
                cellSizes: [
                    .init(column: .fixed(1.0), row: 1.0), .init(column: .fixed(2.0), row: 2.0),
                    .init(column: .fixed(3.0), row: 3.0), .init(column: .fixed(1.0), row: 1.0),
                    .init(column: .fixed(2.0), row: 2.0),
                ], newLineMinOffset: 0.0)
        ]

        #expect(layout.lines.count == 1)
        #expect(layout.lines[0].cellSizes.count == 5)

        #expect(layout.lines[0].cellSizes[0] == .init(column: .fixed(1.0), row: 1.0))
        #expect(layout.lines[0].cellSizes[1] == .init(column: .fixed(2.0), row: 2.0))
        #expect(layout.lines[0].cellSizes[2] == .init(column: .fixed(3.0), row: 3.0))
        #expect(layout.lines[0].cellSizes[3] == .init(column: .fixed(1.0), row: 1.0))
        #expect(layout.lines[0].cellSizes[4] == .init(column: .fixed(2.0), row: 2.0))

        let cellRegions = layout.actualCellRegions
        #expect(cellRegions[0].left == 0.0)
        #expect(cellRegions[0].right == 1.0)
        #expect(cellRegions[0].bottom == 0.0)
        #expect(cellRegions[0].top == 1.0)
        #expect(cellRegions[1].left == 1.0)
        #expect(cellRegions[1].right == 3.0)
        #expect(cellRegions[1].bottom == 0.0)
        #expect(cellRegions[1].top == 2.0)
        #expect(cellRegions[2].left == 0.0)
        #expect(cellRegions[2].right == 3.0)
        #expect(cellRegions[2].bottom == 2.0)
        #expect(cellRegions[2].top == 5.0)
        #expect(cellRegions[3].left == 0.0)
        #expect(cellRegions[3].right == 1.0)
        #expect(cellRegions[3].bottom == 5.0)
        #expect(cellRegions[3].top == 6.0)
        #expect(cellRegions[4].left == 1.0)
        #expect(cellRegions[4].right == 3.0)
        #expect(cellRegions[4].bottom == 5.0)
        #expect(cellRegions[4].top == 7.0)
    }

    @Test func newLineByLines() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 10.0, height: 0.0)),
            preferredCellCount: 5)

        layout.lines = [
            .init(
                cellSizes: [
                    .init(column: .fixed(1.0), row: 1.0), .init(column: .fixed(2.0), row: 2.0),
                    .init(column: .fixed(3.0), row: 3.0),
                ], newLineMinOffset: 0.0),
            .init(
                cellSizes: [
                    .init(column: .fixed(1.0), row: 1.0), .init(column: .fixed(2.0), row: 2.0),
                ],
                newLineMinOffset: 0.0),
        ]

        #expect(layout.lines.count == 2)
        #expect(layout.lines[0].cellSizes.count == 3)
        #expect(layout.lines[1].cellSizes.count == 2)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions[0].left == 0.0)
        #expect(cellRegions[0].right == 1.0)
        #expect(cellRegions[0].bottom == 0.0)
        #expect(cellRegions[0].top == 1.0)
        #expect(cellRegions[1].left == 1.0)
        #expect(cellRegions[1].right == 3.0)
        #expect(cellRegions[1].bottom == 0.0)
        #expect(cellRegions[1].top == 2.0)
        #expect(cellRegions[2].left == 3.0)
        #expect(cellRegions[2].right == 6.0)
        #expect(cellRegions[2].bottom == 0.0)
        #expect(cellRegions[2].top == 3.0)

        #expect(cellRegions[3].left == 0.0)
        #expect(cellRegions[3].right == 1.0)
        #expect(cellRegions[3].bottom == 3.0)
        #expect(cellRegions[3].top == 4.0)
        #expect(cellRegions[4].left == 1.0)
        #expect(cellRegions[4].right == 3.0)
        #expect(cellRegions[4].bottom == 3.0)
        #expect(cellRegions[4].top == 5.0)
    }

    @Test func newLineByFrameAndLines() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 2.0, height: 0.0)),
            preferredCellCount: 5)

        let cellSize = CollectionLayout.CellSize.one

        layout.lines = [
            .init(cellSizes: [cellSize, cellSize, cellSize], newLineMinOffset: 0.0),
            .init(cellSizes: [cellSize, cellSize], newLineMinOffset: 0.0),
        ]

        #expect(layout.lines.count == 2)
        #expect(layout.lines[0].cellSizes.count == 3)
        #expect(layout.lines[1].cellSizes.count == 2)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions[0].left == 0.0)
        #expect(cellRegions[0].right == 1.0)
        #expect(cellRegions[0].bottom == 0.0)
        #expect(cellRegions[0].top == 1.0)
        #expect(cellRegions[1].left == 1.0)
        #expect(cellRegions[1].right == 2.0)
        #expect(cellRegions[1].bottom == 0.0)
        #expect(cellRegions[1].top == 1.0)

        #expect(cellRegions[2].left == 0.0)
        #expect(cellRegions[2].right == 1.0)
        #expect(cellRegions[2].bottom == 1.0)
        #expect(cellRegions[2].top == 2.0)

        #expect(cellRegions[3].left == 0.0)
        #expect(cellRegions[3].right == 1.0)
        #expect(cellRegions[3].bottom == 2.0)
        #expect(cellRegions[3].top == 3.0)
        #expect(cellRegions[4].left == 1.0)
        #expect(cellRegions[4].right == 2.0)
        #expect(cellRegions[4].bottom == 2.0)
        #expect(cellRegions[4].top == 3.0)
    }

    @Test func setCellSizesZeroWidth() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 3.0, height: 0.0)),
            preferredCellCount: 3, defaultCellSize: .init(column: .fixed(0.0), row: 1.0),
            borders: .init(left: 1.0, right: 1.0))

        #expect(layout.actualCellCount == 3)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions[0].left == 1.0)
        #expect(cellRegions[0].right == 1.0)
        #expect(cellRegions[0].bottom == 0.0)
        #expect(cellRegions[0].top == 1.0)

        #expect(cellRegions[1].left == 1.0)
        #expect(cellRegions[1].right == 1.0)
        #expect(cellRegions[1].bottom == 0.0)
        #expect(cellRegions[1].top == 1.0)

        #expect(cellRegions[2].left == 1.0)
        #expect(cellRegions[2].right == 1.0)
        #expect(cellRegions[2].bottom == 0.0)
        #expect(cellRegions[2].top == 1.0)
    }

    @Test func setRowSpacing() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 2.0, height: 0.0)),
            preferredCellCount: 3, defaultCellSize: .one)

        #expect(layout.rowSpacing == 0.0)

        do {
            let cellRegions = layout.actualCellRegions

            #expect(cellRegions[0].left == 0.0)
            #expect(cellRegions[0].bottom == 0.0)
            #expect(cellRegions[1].left == 1.0)
            #expect(cellRegions[1].bottom == 0.0)
            #expect(cellRegions[2].left == 0.0)
            #expect(cellRegions[2].bottom == 1.0)
        }

        layout.rowSpacing = 1.0

        #expect(layout.rowSpacing == 1.0)

        do {
            let cellRegions = layout.actualCellRegions

            #expect(cellRegions[0].left == 0.0)
            #expect(cellRegions[0].bottom == 0.0)
            #expect(cellRegions[1].left == 1.0)
            #expect(cellRegions[1].bottom == 0.0)
            #expect(cellRegions[2].left == 0.0)
            #expect(cellRegions[2].bottom == 2.0)
        }
    }

    @Test func setColSpacing() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 3.0, height: 0.0)),
            preferredCellCount: 3, defaultCellSize: .one)

        #expect(layout.colSpacing == 0.0)

        do {
            let cellRegions = layout.actualCellRegions

            #expect(cellRegions[0].left == 0.0)
            #expect(cellRegions[0].bottom == 0.0)
            #expect(cellRegions[1].left == 1.0)
            #expect(cellRegions[1].bottom == 0.0)
            #expect(cellRegions[2].left == 2.0)
            #expect(cellRegions[2].bottom == 0.0)
        }

        layout.colSpacing = 1.0

        #expect(layout.colSpacing == 1.0)

        do {
            let cellRegions = layout.actualCellRegions

            #expect(cellRegions[0].left == 0.0)
            #expect(cellRegions[0].bottom == 0.0)
            #expect(cellRegions[1].left == 2.0)
            #expect(cellRegions[1].bottom == 0.0)
            #expect(cellRegions[2].left == 0.0)
            #expect(cellRegions[2].bottom == 1.0)
        }
    }

    @Test func setAligmnent() {
        let layout = CollectionLayout()

        layout.alignment = .mid

        #expect(layout.alignment == .mid)

        layout.alignment = .max

        #expect(layout.alignment == .max)
    }

    @Test func alignmentMid() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 0.0)),
            preferredCellCount: 3, defaultCellSize: .init(column: .fixed(2.0), row: 1.0),
            alignment: .mid)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions[0].left == 0.5)
        #expect(cellRegions[0].bottom == 0.0)
        #expect(cellRegions[1].left == 2.5)
        #expect(cellRegions[1].bottom == 0.0)
        #expect(cellRegions[2].left == 1.5)
        #expect(cellRegions[2].bottom == 1.0)
    }

    @Test func alignmentMax() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 0.0)),
            preferredCellCount: 3, defaultCellSize: .init(column: .fixed(2.0), row: 1.0),
            alignment: .max)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions[0].left == 1.0)
        #expect(cellRegions[0].bottom == 0.0)
        #expect(cellRegions[1].left == 3.0)
        #expect(cellRegions[1].bottom == 0.0)
        #expect(cellRegions[2].left == 3.0)
        #expect(cellRegions[2].bottom == 1.0)
    }

    @Test func setDirection() {
        let layout = CollectionLayout()

        layout.direction = .horizontal

        #expect(layout.direction == .horizontal)
    }

    @Test func setRowOrder() {
        let layout = CollectionLayout()

        layout.rowOrder = .descending

        #expect(layout.rowOrder == .descending)
    }

    @Test func setColOrder() {
        let layout = CollectionLayout()

        layout.columnOrder = .descending

        #expect(layout.columnOrder == .descending)
    }

    // row ↑ col →
    // |-|-|-|-|-|
    // |x|2|2| | |
    // |-|-|-|-|-|
    // |x|0|0|1|1|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func verticalEachAscendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(2.0), row: 1.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .vertical,
            rowOrder: .ascending,
            colOrder: .ascending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 3.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row ↓ col →
    // |-|-|-|-|-|
    // |x|0|0|1|1|
    // |-|-|-|-|-|
    // |x|2|2| | |
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func verticalRowDescendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(2.0), row: 1.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .vertical,
            rowOrder: .descending,
            colOrder: .ascending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 3.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row ↑ col ←
    // |-|-|-|-|-|
    // |x| | |2|2|
    // |-|-|-|-|-|
    // |x|1|1|0|0|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func verticalColDescendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(2.0), row: 1.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .vertical,
            rowOrder: .ascending,
            colOrder: .descending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 3.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 3.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row ↓ col ←
    // |-|-|-|-|-|
    // |x|1|1|0|0|
    // |-|-|-|-|-|
    // |x|2|2| | |
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func verticalEachDescendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(2.0), row: 1.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .vertical,
            rowOrder: .descending,
            colOrder: .descending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 3.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 3.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row → col ↑
    // |-|-|-|-|-|
    // |x|1|1| | |
    // |-|-|-|-|-|
    // |x|0|0|2|2|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func horizontalEachAscendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(1.0), row: 2.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .horizontal,
            rowOrder: .ascending,
            colOrder: .ascending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 3.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row ← col ↑
    // |-|-|-|-|-|
    // |x| | |1|1|
    // |-|-|-|-|-|
    // |x|2|2|0|0|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func horizontalRowDescendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(1.0), row: 2.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .horizontal,
            rowOrder: .descending,
            colOrder: .ascending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 3.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 3.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row → col ↓
    // |-|-|-|-|-|
    // |x|0|0|2|2|
    // |-|-|-|-|-|
    // |x|1|1| | |
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func horizontalColDescendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(1.0), row: 2.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .horizontal,
            rowOrder: .ascending,
            colOrder: .descending)

        let cellRegions = layout.actualCellRegions

        #expect(cellRegions.count == 3)
        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 1.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 3.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
    }

    // row ← col ↓
    // |-|-|-|-|-|
    // |x|2|2|0|0|
    // |-|-|-|-|-|
    // |x| | |1|1|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|
    // |x|x|x|x|x|
    // |-|-|-|-|-|

    @Test func horizontalEachDescendingOrder() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 5.0, height: 4.0)),
            preferredCellCount: 3,
            defaultCellSize: .init(column: .fixed(1.0), row: 2.0),
            borders: .init(bottom: 2.0, left: 1.0),
            direction: .horizontal,
            rowOrder: .descending,
            colOrder: .descending)

        let cellRegions = layout.actualCellRegions

        #expect(
            cellRegions[0]
                == Region(origin: .init(x: 3.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[1]
                == Region(origin: .init(x: 3.0, y: 2.0), size: .init(width: 2.0, height: 1.0)))
        #expect(
            cellRegions[2]
                == Region(origin: .init(x: 1.0, y: 3.0), size: .init(width: 2.0, height: 1.0)))
    }

    @Test func isEqualLine() {
        let line1a = CollectionLayout.Line(
            cellSizes: [.init(column: .fixed(1.0), row: 2.0)], newLineMinOffset: 3.0)
        let line1b = CollectionLayout.Line(
            cellSizes: [.init(column: .fixed(1.0), row: 2.0)], newLineMinOffset: 3.0)
        let line2 = CollectionLayout.Line(
            cellSizes: [.init(column: .fixed(1.0), row: 2.0)], newLineMinOffset: 4.0)
        let line3 = CollectionLayout.Line(
            cellSizes: [.init(column: .fixed(5.0), row: 6.0)], newLineMinOffset: 3.0)

        #expect(line1a == line1a)
        #expect(line1a == line1b)
        #expect(line1a != line2)
        #expect(line1a != line3)
    }

    @Test func actualFrameLayoutSource() {
        let layout = CollectionLayout(
            frame: .init(origin: .zero, size: .init(width: 2.0, height: 2.0)))

        var notified: [Region] = []

        let canceller = layout.actualFrameLayoutSource.layoutRegionPublisher.sink { region in
            notified.append(region)
        }

        #expect(notified.count == 1)
        #expect(notified[0] == .zero)

        layout.preferredCellCount = 1

        #expect(notified.count == 2)
        #expect(notified[1] == .init(origin: .zero, size: .one))

        canceller.cancel()
    }
}
