import Testing

@testable import BrassBand

@MainActor
struct LayoutLinkAnimatorTests {
    @Test func animation() async throws {
        let beginTime = Date.now

        let rootAction = ParallelAction()
        let source = LayoutValueGuide()
        let destination = LayoutValueGuide()

        source.value = 0.0
        destination.value = 1.0

        let valueLink = LayoutValueLink(source: source, destination: destination)
        let animator = LayoutLinkAnimator(
            rootAction: rootAction, layoutLinks: valueLink.layoutValueLinks, duration: .seconds(1),
            now: { beginTime })

        #expect(destination.value == 1.0)

        source.value = 2.0

        #expect(destination.value == 1.0)

        #expect(!rootAction.rawAction.update(beginTime))

        #expect(destination.value == 1.0)

        #expect(!rootAction.rawAction.update(beginTime + 0.5))

        #expect(destination.value == 1.5)

        #expect(rootAction.rawAction.update(beginTime + 1.1))

        #expect(destination.value == 2.0)
    }
}
