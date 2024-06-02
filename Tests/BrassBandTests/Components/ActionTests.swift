import Synchronization
import Testing

@testable import BrassBand

struct ActionTests {
    @Test func makeAction() {
        let action = Action()

        #expect(action.group == nil)
        #expect(action.delay == .zero)

        let beginTime = action.beginTime
        let time = Date.now

        #expect(beginTime <= time)
        #expect(time - 0.1 < beginTime)
    }

    @MainActor
    @Test func finishedByOverTime() {
        let beginTime = Date.now
        let action = Action.Continuous(duration: .seconds(1), beginTime: beginTime).action

        #expect(!action.update(beginTime + 0.999))
        #expect(action.update(beginTime + 1.0))
    }

    @Test func makeActionWithParameters() {
        let group = ActionGroup()
        let time = Date.now
        let action = Action(
            group: group, beginTime: time, delay: .seconds(1), timeUpdater: { (_, _) in false },
            completion: {})

        #expect(action.group == group)
        #expect(action.beginTime == time)
        #expect(action.delay == .seconds(1))
    }

    @MainActor
    @Test func beginTime() {
        let time = Date.now
        let action = Action(beginTime: time + 1.0)

        #expect(!action.update(time))
        #expect(!action.update(time + 0.999))
        #expect(action.update(time + 1.0))
    }

    @MainActor
    @Test func completion() {
        let time = Date.now
        let completed = Atomic<Bool>(false)
        let action = Action.Continuous(
            duration: .seconds(1), beginTime: time,
            completion: { completed.store(true, ordering: .relaxed) }
        ).action

        #expect(!action.update(time))

        #expect(completed.load(ordering: .relaxed) == false)

        #expect(!action.update(time + 0.5))

        #expect(completed.load(ordering: .relaxed) == false)

        #expect(action.update(time + 1.0))

        #expect(completed.load(ordering: .relaxed) == true)
    }

    @MainActor
    @Test func continuousWithDelay() {
        let time = Date.now
        var completed = false
        let updatedValue = Atomic<Float>(-1.0)
        let action = Action.Continuous(
            duration: .seconds(1), valueUpdater: { updatedValue.store($0, ordering: .relaxed) },
            beginTime: time, delay: .seconds(2), completion: { completed = true }
        ).action

        #expect(!action.update(time))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == -1.0)

        #expect(!action.update(time + 1.999))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == -1.0)

        #expect(!action.update(time + 2.0))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.0)

        #expect(!action.update(time + 2.999))
        #expect(!completed)

        #expect(action.update(time + 3.0))
        #expect(completed)
        #expect(updatedValue.load(ordering: .relaxed) == 1.0)
    }

    @MainActor
    @Test func continuousWithLoop() {
        let time = Date.now
        var completed = false
        let updatedValue = Atomic<Float>(-1.0)
        let action = Action.Continuous(
            duration: .seconds(1), loop: .count(2),
            valueUpdater: { updatedValue.store($0, ordering: .relaxed) }, beginTime: time,
            completion: { completed = true }
        ).action

        #expect(!action.update(time - 0.001))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == -1.0)

        #expect(!action.update(time))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.0)

        #expect(!action.update(time + 0.5))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.5)

        #expect(!action.update(time + 1.0))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.0)

        #expect(!action.update(time + 1.5))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.5)

        #expect(action.update(time + 2.0))
        #expect(completed)
        #expect(updatedValue.load(ordering: .relaxed) == 1.0)
    }

    @MainActor
    @Test func continuousWithMinusLoop() {
        let time = Date.now
        var completed = false
        let updatedValue = Atomic<Float>(-1.0)
        let action = Action.Continuous(
            duration: .seconds(1), loop: .count(-1),
            valueUpdater: { updatedValue.store($0, ordering: .relaxed) }, beginTime: time,
            completion: { completed = true }
        ).action

        #expect(action.update(time))
        #expect(completed)
    }

    @MainActor
    @Test func continousWithInfinityLoop() {
        let time = Date.now
        var completed = false
        let updatedValue = Atomic<Float>(-1.0)
        let action = Action.Continuous(
            duration: .seconds(1), loop: .infinity,
            valueUpdater: { updatedValue.store($0, ordering: .relaxed) }, beginTime: time,
            completion: { completed = true }
        ).action

        #expect(!action.update(time - 0.001))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == -1.0)

        #expect(!action.update(time))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.0)

        #expect(!action.update(time + 0.5))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.5)

        #expect(!action.update(time + 1.0))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.0)

        #expect(!action.update(time + 10000.0))
        #expect(!completed)
        #expect(updatedValue.load(ordering: .relaxed) == 0.0)
    }

    @MainActor
    @Test func sequence() {
        var firstCompleted = false
        var rotateCompleted = false
        var endCompleted = false
        var scaleCompleted = false
        var sequenceCompleted = false

        let firstAction = Action(completion: { firstCompleted = true })
        let continuousAction1 = Action.Continuous(
            duration: .seconds(1), completion: { rotateCompleted = true })
        let endAction = Action(completion: { endCompleted = true })
        let continuousAction2 = Action.Continuous(
            duration: .seconds(0.5), completion: { scaleCompleted = true })

        let time = Date.now

        let sequenceAction = Action.Sequence(
            elements: [
                .init(firstAction), .init(continuousAction1, duration: .seconds(1)),
                .init(endAction), .init(continuousAction2, duration: .seconds(0.5)),
            ], beginTime: time + 1.0,
            completion: { sequenceCompleted = true }
        ).action

        #expect(!sequenceAction.update(time))

        #expect(!firstCompleted)
        #expect(!rotateCompleted)
        #expect(!endCompleted)
        #expect(!scaleCompleted)
        #expect(!sequenceCompleted)

        #expect(!sequenceAction.update(time + 0.999))

        #expect(!firstCompleted)
        #expect(!rotateCompleted)
        #expect(!endCompleted)
        #expect(!scaleCompleted)
        #expect(!sequenceCompleted)

        #expect(!sequenceAction.update(time + 1.0))

        #expect(firstCompleted)
        #expect(!rotateCompleted)
        #expect(!endCompleted)
        #expect(!scaleCompleted)
        #expect(!sequenceCompleted)

        #expect(!sequenceAction.update(time + 1.999))

        #expect(firstCompleted)
        #expect(!rotateCompleted)
        #expect(!endCompleted)
        #expect(!scaleCompleted)
        #expect(!sequenceCompleted)

        #expect(!sequenceAction.update(time + 2.0))

        #expect(firstCompleted)
        #expect(rotateCompleted)
        #expect(endCompleted)
        #expect(!scaleCompleted)
        #expect(!sequenceCompleted)

        #expect(!sequenceAction.update(time + 2.499))

        #expect(firstCompleted)
        #expect(rotateCompleted)
        #expect(endCompleted)
        #expect(!scaleCompleted)
        #expect(!sequenceCompleted)

        #expect(sequenceAction.update(time + 2.5))

        #expect(firstCompleted)
        #expect(rotateCompleted)
        #expect(endCompleted)
        #expect(scaleCompleted)
        #expect(sequenceCompleted)
    }
}
