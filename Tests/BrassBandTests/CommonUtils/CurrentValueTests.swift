import BrassBand
import Testing

struct CurrentValueTests {
    class Object {
        @CurrentValue var currentValue: Int = 0
    }

    @Test func wrappedValue() {
        let object = Object()

        #expect(object.currentValue == 0)

        object.currentValue = 1

        #expect(object.currentValue == 1)
    }

    @Test func projectedValue() {
        let object = Object()

        var received: [Int] = []

        let canceller = object.$currentValue.sink { value in
            received.append(value)
        }

        #expect(received.count == 1)
        #expect(received[0] == 0)

        object.currentValue = 10

        #expect(received.count == 2)
        #expect(received[1] == 10)

        canceller.cancel()
    }
}
