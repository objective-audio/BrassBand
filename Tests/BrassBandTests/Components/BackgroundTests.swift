import Testing

@testable import BrassBand

@MainActor
struct BackgroundTest {
    @Test func initial() {
        let background = Background()

        #expect(background.color.rgb == .white)
        #expect(background.color.alpha == .one)
    }

    @Test func rgbColor() {
        let background = Background()

        #expect(background.color.rgb == .white)

        background.color.rgb = .brown

        #expect(background.color.rgb == .brown)
    }

    @Test func alpha() {
        let background = Background()

        #expect(background.color.alpha == .one)

        background.color.alpha = .init(value: 0.5)

        #expect(background.color.alpha.value == 0.5)
    }

    @Test func color() {
        let background = Background()

        #expect(background.color == Color(rgb: .white, alpha: .one))

        background.color = .init(rgb: .brown, alpha: .init(value: 0.25))

        #expect(background.color == .init(rgb: .brown, alpha: .init(value: 0.25)))
    }

    @Test func fetchAndClearUpdates() {
        let background = Background()

        do {
            var treeUpdates = TreeUpdates()

            background.fetchUpdates(&treeUpdates)

            #expect(treeUpdates.backgroundUpdates == .all)
        }

        do {
            var treeUpdates = TreeUpdates()

            background.clearUpdates()
            background.fetchUpdates(&treeUpdates)

            #expect(!treeUpdates.isAnyUpdated)
        }

        do {
            var treeUpdates = TreeUpdates()

            background.clearUpdates()
            background.color.rgb = .init(repeating: 1.0)
            background.fetchUpdates(&treeUpdates)

            #expect(treeUpdates.backgroundUpdates == [.color])
        }

        do {
            var treeUpdates = TreeUpdates()

            background.clearUpdates()
            background.color.alpha = .init(value: 0.5)
            background.fetchUpdates(&treeUpdates)

            #expect(treeUpdates.backgroundUpdates == [.color])
        }

        do {
            var treeUpdates = TreeUpdates()

            background.clearUpdates()
            background.color = .init(repeating: 1.0)
            background.fetchUpdates(&treeUpdates)

            #expect(treeUpdates.backgroundUpdates == [.color])
        }
    }
}
