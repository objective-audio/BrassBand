import BrassBand
import Testing

@MainActor
struct NodeHierarchyTests {
    @Test func hierarchy() {
        let parentNode = Node()
        let subNode1 = Node()
        let subNode2 = Node()

        #expect(parentNode.subNodes.isEmpty)
        #expect(subNode1.parent == nil)
        #expect(subNode2.parent == nil)

        parentNode.appendSubNode(subNode1)

        #expect(parentNode.subNodes.count == 1)
        #expect(subNode1.parent != nil)

        parentNode.appendSubNode(subNode2)

        #expect(parentNode.subNodes.count == 2)
        #expect(subNode1.parent != nil)
        #expect(subNode2.parent != nil)

        #expect(subNode1.parent === parentNode)
        #expect(subNode2.parent === parentNode)

        subNode1.removeFromSuper()

        #expect(parentNode.subNodes.count == 1)
        #expect(subNode1.parent == nil)
        #expect(subNode2.parent != nil)

        #expect(parentNode.subNodes[0] === subNode2)

        subNode2.removeFromSuper()

        #expect(parentNode.subNodes.isEmpty)
        #expect(subNode1.parent == nil)
        #expect(subNode2.parent == nil)
    }

    @Test func removeSubNode() {
        let parentNode = Node()
        let subNode1 = Node()
        let subNode2 = Node()

        parentNode.appendSubNode(subNode1)
        parentNode.appendSubNode(subNode2)

        #expect(parentNode.subNodes.count == 2)

        parentNode.removeSubNode(at: 0)

        #expect(parentNode.subNodes.count == 1)
        #expect(parentNode.subNodes[0] === subNode2)
        #expect(subNode1.parent == nil)
        #expect(subNode2.parent != nil)

        parentNode.removeSubNode(at: 0)

        #expect(parentNode.subNodes.isEmpty)
        #expect(subNode2.parent == nil)
    }

    @Test func removeAllSubNodes() {
        let parentNode = Node()
        let subNode1 = Node()
        let subNode2 = Node()

        parentNode.appendSubNode(subNode1)
        parentNode.appendSubNode(subNode2)

        #expect(parentNode.subNodes.count == 2)

        parentNode.removeAllSubNodes()

        #expect(parentNode.subNodes.isEmpty)
        #expect(subNode1.parent == nil)
        #expect(subNode2.parent == nil)
    }

    @Test func insertSubNode() {
        let parentNode = Node()
        let subNode1 = Node()
        let subNode2 = Node()
        let subNode3 = Node()

        parentNode.appendSubNode(subNode1)
        parentNode.appendSubNode(subNode3)
        parentNode.insertSubNode(subNode2, at: 1)

        #expect(parentNode.subNodes.count == 3)
        #expect(parentNode.subNodes[0] === subNode1)
        #expect(parentNode.subNodes[1] === subNode2)
        #expect(parentNode.subNodes[2] === subNode3)
    }

    @Test func parentChangedWhenAppendSubNode() {
        let parentNode1 = Node()
        let parentNode2 = Node()

        let subNode = Node()

        parentNode1.appendSubNode(subNode)

        #expect(parentNode1.subNodes.count == 1)
        #expect(parentNode2.subNodes.isEmpty)

        parentNode2.appendSubNode(subNode)

        #expect(parentNode1.subNodes.isEmpty)
        #expect(parentNode2.subNodes.count == 1)
    }
}
