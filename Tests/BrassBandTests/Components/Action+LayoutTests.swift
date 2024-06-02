import Testing

@testable import BrassBand

@MainActor
struct Action_LayoutTest {
    @Test func initializeByDefault() async throws {
        let guide = LayoutValueGuide()

        let actionLayout = Action.Layout(target: guide, beginValue: 0.0, endValue: 1.0)

        #expect(actionLayout.group == nil)
        #expect(actionLayout.target === guide)
        #expect(actionLayout.beginValue == 0.0)
        #expect(actionLayout.endValue == 1.0)
        #expect(actionLayout.duration == .seconds(0.3))
        #expect(actionLayout.loop == .count(1))
        #expect(actionLayout.beginTime < Date.now + 0.1)
        #expect(actionLayout.beginTime > Date.now - 0.1)
    }
}
