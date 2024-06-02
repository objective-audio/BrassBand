import Testing

@testable import BrassBand

@MainActor
struct NodeContentContainerTests {
    @Test func defaultInit() async throws {
        let container = Node.ContentContainer()

        #expect(container.node.renderable is Node.Content)
        #expect(container.node.content != nil)
        #expect(container.content.meshes.isEmpty)
        #expect(container.content.color == .init(repeating: 1.0))
    }

    @Test func initWithParams() async throws {
        let meshA = Mesh()
        let meshB = Mesh()
        let container = Node.ContentContainer(
            meshes: [meshA, meshB], color: .init(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4))

        #expect(container.node.renderable is Node.Content)
        #expect(container.node.content != nil)
        #expect(container.content.meshes.count == 2)
        #expect(container.content.color == .init(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4))
    }
}
