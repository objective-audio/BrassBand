import BrassBand
import Testing

struct WeakTests {
    @Test func value() {
        class Object {}

        let weakObject = Weak<Object>(nil)

        #expect(weakObject.value == nil)

        do {
            let object = Object()

            weakObject.value = object

            #expect(weakObject.value != nil)
        }

        #expect(weakObject.value == nil)
    }
}
