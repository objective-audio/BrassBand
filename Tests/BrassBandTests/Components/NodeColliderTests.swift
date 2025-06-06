import BrassBand
import Testing

@MainActor
struct NodeColliderTests {
    @Test func colliders() {
        let node = Node.empty

        #expect(node.colliders.isEmpty)

        let colliderA = Collider()
        let colliderB = Collider()

        node.colliders = [colliderA, colliderB]

        #expect(node.colliders.count == 2)
        #expect(node.colliders[0] === colliderA)
        #expect(node.colliders[1] === colliderB)
    }
}
