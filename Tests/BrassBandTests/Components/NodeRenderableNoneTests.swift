import Testing

@testable import BrassBand

private final class SubNodeStub: Node.SubNode {
    var fetchUpdatesHandler: (inout BrassBand.TreeUpdates) -> Void = { _ in }
    var buildRenderInfoHandler: (inout BrassBand.NodeRenderInfo) -> Void = { _ in }

    func fetchUpdates(_ treeUpdates: inout BrassBand.TreeUpdates) {
        fetchUpdatesHandler(&treeUpdates)
    }

    func buildRenderInfo(_ renderInfo: inout BrassBand.NodeRenderInfo) {
        buildRenderInfoHandler(&renderInfo)
    }
}

private struct SystemStub: Node.RenderableNone.MetalSystem {}

private struct Called {
    enum Kind {
        case fetchUpdates
        case buildRenderInfo
    }
    var kind: Kind
    var index: Int
    var matrix: simd_float4x4?
    var meshMatrix: simd_float4x4?
}

@MainActor
struct NodeRenderableNoneTests {
    @Test func render() throws {
        let renderable = Node.RenderableNone()

        var treeUpdates = TreeUpdates()
        renderable.fetchUpdates(&treeUpdates)

        #expect(!treeUpdates.isAnyUpdated)

        try renderable.prepareForRendering(system: SystemStub())

        let translatedMatrix = simd_float4x4.translation(x: 1.0, y: 2.0)
        let scaledMatrix = simd_float4x4.scaling(scale: .init(width: 3.0, height: 4.0))

        var called: [Called] = []
        var renderInfo = NodeRenderInfo()
        renderInfo.matrix = translatedMatrix
        renderInfo.meshMatrix = scaledMatrix
        let subNodes: [SubNodeStub] = [.init(), .init()]

        for (index, subNode) in subNodes.enumerated() {
            subNode.fetchUpdatesHandler = { _ in
                called.append(.init(kind: .fetchUpdates, index: index))
            }
            subNode.buildRenderInfoHandler = { renderInfo in
                called.append(
                    .init(
                        kind: .buildRenderInfo, index: index, matrix: renderInfo.matrix,
                        meshMatrix: renderInfo.meshMatrix))
                renderInfo.matrix = matrix_identity_float4x4
                renderInfo.meshMatrix = matrix_identity_float4x4
            }
        }

        renderable.buildRenderInfo(&renderInfo, subNodes: subNodes)

        #expect(called.count == 2)
        #expect(called[0].kind == .buildRenderInfo)
        #expect(called[0].index == 0)
        #expect(called[0].matrix == translatedMatrix)
        #expect(called[0].meshMatrix == scaledMatrix)
        #expect(called[1].kind == .buildRenderInfo)
        #expect(called[1].index == 1)
        #expect(called[1].matrix == translatedMatrix)
        #expect(called[1].meshMatrix == scaledMatrix)

        renderable.clearUpdates()

        #expect(!treeUpdates.isAnyUpdated)
    }
}
