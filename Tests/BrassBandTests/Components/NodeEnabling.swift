import BrassBand
import Testing

@MainActor
struct NodeEnablingTest {
    @Test func isEnabled() {
        let node = Node.empty

        #expect(node.isEnabled == true)

        node.isEnabled = false

        #expect(node.isEnabled == false)
    }
}
