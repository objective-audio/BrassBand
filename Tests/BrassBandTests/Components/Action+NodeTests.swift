import Testing

@testable import BrassBand

struct Action_NodeTests {
    @Test @MainActor func translation() {
        var completed = false
        let node = Node.empty
        let beginTime = Date.now

        let action = Action.Translation(
            target: node, beginPosition: .init(x: 0.0, y: 0.0), endPosition: .init(x: 1.0, y: 2.0),
            duration: .seconds(1), beginTime: beginTime, completion: { completed = true }
        ).action

        #expect(!action.update(beginTime))
        #expect(!completed)
        #expect(node.geometry.position == .init(x: 0.0, y: 0.0))

        #expect(!action.update(beginTime + 0.5))
        #expect(!completed)
        #expect(node.geometry.position == .init(x: 0.5, y: 1.0))

        #expect(action.update(beginTime + 1.0))
        #expect(completed)
        #expect(node.geometry.position == .init(x: 1.0, y: 2.0))
    }

    @Test @MainActor func rotation() {
        var completed = false
        let node = Node.empty
        let beginTime = Date.now

        let action = Action.Rotation(
            target: node, beginAngle: .init(degrees: 0.0), endAngle: .init(degrees: 360.0),
            duration: .seconds(1), beginTime: beginTime, completion: { completed = true }
        ).action

        #expect(!action.update(beginTime))
        #expect(!completed)
        #expect(node.geometry.angle == .init(degrees: 0.0))

        #expect(!action.update(beginTime + 0.5))
        #expect(!completed)
        #expect(node.geometry.angle == .init(degrees: 180.0))

        #expect(action.update(beginTime + 1.0))
        #expect(completed)
        #expect(node.geometry.angle == .init(degrees: 360.0))
    }

    @Test @MainActor func rotationWithShortest() {
        var completed = false
        let node = Node.empty
        let beginTime = Date.now

        let action = Action.Rotation(
            target: node, beginAngle: .init(degrees: 0.0), endAngle: .init(degrees: 270),
            isShortest: true, duration: .seconds(1), beginTime: beginTime,
            completion: { completed = true }
        ).action

        #expect(!action.update(beginTime))
        #expect(!completed)
        #expect(node.geometry.angle == .init(degrees: 360.0))

        #expect(!action.update(beginTime + 0.5))
        #expect(!completed)
        #expect(node.geometry.angle == .init(degrees: 315.0))

        #expect(action.update(beginTime + 1.0))
        #expect(completed)
        #expect(node.geometry.angle == .init(degrees: 270.0))
    }

    @Test @MainActor func scaling() {
        var completed = false
        let node = Node.empty
        let beginTime = Date.now

        let action = Action.Scaling(
            target: node, beginScale: .init(width: 0.0, height: 0.0),
            endScale: .init(width: 1.0, height: 2.0), duration: .seconds(1), beginTime: beginTime,
            completion: { completed = true }
        ).action

        #expect(!action.update(beginTime))
        #expect(!completed)
        #expect(node.geometry.scale == .init(width: 0.0, height: 0.0))

        #expect(!action.update(beginTime + 0.5))
        #expect(!completed)
        #expect(node.geometry.scale == .init(width: 0.5, height: 1.0))

        #expect(action.update(beginTime + 1.0))
        #expect(completed)
        #expect(node.geometry.scale == .init(width: 1.0, height: 2.0))
    }

    @Test @MainActor func coloring() {
        var completed = false
        let container = Node.ContentContainer()
        let beginTime = Date.now

        let action = Action.Coloring(
            target: container.content,
            beginColor: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
            endColor: .init(red: 1.0, green: 0.5, blue: 0.25, alpha: 0.0), duration: .seconds(1),
            beginTime: beginTime, completion: { completed = true }
        ).action

        #expect(!action.update(beginTime))
        #expect(!completed)
        #expect(container.content.color == .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0))

        #expect(!action.update(beginTime + 0.5))
        #expect(!completed)
        #expect(
            container.content.color == .init(red: 0.5, green: 0.25, blue: 0.125, alpha: 0.0))

        #expect(action.update(beginTime + 1.0))
        #expect(completed)
        #expect(container.content.color == .init(red: 1.0, green: 0.5, blue: 0.25, alpha: 0.0))
    }

    @Test @MainActor func fading() {
        var completed = false
        let container = Node.ContentContainer()
        let beginTime = Date.now

        let action = Action.Fading(
            target: container.content, beginAlpha: .init(value: 0.0),
            endAlpha: .init(value: 1.0),
            duration: .seconds(1),
            beginTime: beginTime, completion: { completed = true }
        ).action

        #expect(!action.update(beginTime))
        #expect(!completed)
        #expect(container.content.color.alpha == .init(value: 0.0))

        #expect(!action.update(beginTime + 0.5))
        #expect(!completed)
        #expect(container.content.color.alpha == .init(value: 0.5))

        #expect(action.update(beginTime + 1.0))
        #expect(completed)
        #expect(container.content.color.alpha == .init(value: 1.0))
    }
}
