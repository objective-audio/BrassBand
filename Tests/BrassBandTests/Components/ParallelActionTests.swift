import Testing

@testable import BrassBand

struct ParallelActionTests {
    @Test func make() {
        let action = ParallelAction()

        #expect(action.actionCount == 0)
    }

    @MainActor
    @Test func update() {
        let time = Date.now

        var completed1 = false
        var completed2 = false
        var completed3 = false

        let action1 = Action.Continuous(
            duration: .seconds(1), beginTime: time, completion: { completed1 = true })
        let action2 = Action.Continuous(
            duration: .seconds(2), beginTime: time, completion: { completed2 = true })

        let parallelAction = ParallelAction(actions: [action1, action2])

        let action3 = Action.Continuous(
            duration: .seconds(3), beginTime: time, completion: { completed3 = true })
        parallelAction.insert(action3)

        #expect(parallelAction.actionCount == 3)

        #expect(!parallelAction.rawAction.update(time))
        #expect(parallelAction.actionCount == 3)

        #expect(!parallelAction.rawAction.update(time + 0.999))
        #expect(parallelAction.actionCount == 3)
        #expect(!completed1)

        #expect(!parallelAction.rawAction.update(time + 1.0))
        #expect(parallelAction.actionCount == 2)
        #expect(completed1)

        #expect(!parallelAction.rawAction.update(time + 1.999))
        #expect(parallelAction.actionCount == 2)
        #expect(!completed2)

        #expect(!parallelAction.rawAction.update(time + 2.0))
        #expect(parallelAction.actionCount == 1)
        #expect(completed2)

        #expect(!parallelAction.rawAction.update(time + 2.999))
        #expect(parallelAction.actionCount == 1)
        #expect(!completed3)

        #expect(parallelAction.rawAction.update(time + 3.0))
        #expect(parallelAction.actionCount == 0)
        #expect(completed3)
    }

    @MainActor
    @Test func insert() {
        let time = Date.now
        let parallelBeginTime = time - 1.0

        let action1 = Action.Continuous(duration: .seconds(1), beginTime: time)
        let action2 = Action.Continuous(duration: .seconds(2), beginTime: time)

        let parallelAction = ParallelAction(actions: [], beginTime: parallelBeginTime)

        #expect(parallelAction.actionCount == 0)
        #expect(parallelAction.rawAction.update(time))
        #expect(parallelAction.actionCount == 0)

        parallelAction.insert(action1)

        #expect(!parallelAction.rawAction.update(time))
        #expect(parallelAction.actionCount == 1)

        parallelAction.insert(action2)

        #expect(!parallelAction.rawAction.update(time))
        #expect(parallelAction.actionCount == 2)
    }

    @MainActor
    @Test func removeForGroup() {
        let time = Date.now

        let group1 = ActionGroup()
        let group2 = ActionGroup()
        let action1 = Action.Continuous(duration: .seconds(1), group: group1, beginTime: time)
        let action2 = Action.Continuous(duration: .seconds(2), group: group2, beginTime: time)

        let parallelAction = ParallelAction(actions: [action1, action2])

        #expect(parallelAction.actionCount == 2)

        parallelAction.remove(for: group1)

        #expect(!parallelAction.rawAction.update(time + 1.5))
        #expect(parallelAction.actionCount == 1)

        parallelAction.remove(for: group2)

        #expect(parallelAction.actionCount == 0)
    }

    @MainActor
    @Test func removeForActionId() {
        let time = Date.now

        let parallelAction = ParallelAction()

        let action1 = Action.Continuous(duration: .seconds(1), beginTime: time)
        let action2 = Action.Continuous(duration: .seconds(2), beginTime: time)

        let actionId1 = parallelAction.insert(action1)
        let actionId2 = parallelAction.insert(action2)

        #expect(parallelAction.actionCount == 2)

        parallelAction.remove(for: actionId1)

        #expect(!parallelAction.rawAction.update(time + 1.5))
        #expect(parallelAction.actionCount == 1)

        parallelAction.remove(for: actionId2)

        #expect(parallelAction.actionCount == 0)
    }
}
