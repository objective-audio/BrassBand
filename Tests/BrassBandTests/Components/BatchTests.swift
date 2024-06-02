import Testing

@testable import BrassBand

private final class RenderEncodableStub: RenderEncodable {
    var meshes: [Mesh] = []

    func appendMesh(_ mesh: Mesh) {
        meshes.append(mesh)
    }
}

@MainActor
struct BatchTests {
    @Test(.enabled(if: isMetalSystemAvailable))
    func buildRenderInfo_smoke() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))

        let plane0 = RectPlane(rectCount: 1)
        let plane1 = RectPlane(rectCount: 1)
        let subNodes = [plane0.node, plane1.node]
        let batch = Batch()

        do {
            // rebuild

            let encodable = RenderEncodableStub()
            var renderInfo = NodeRenderInfo(encodable: encodable)
            var treeUpdates = TreeUpdates()

            batch.fetchUpdates(&treeUpdates)

            try batch.prepareForRendering(system: system)
            batch.buildRenderInfo(&renderInfo, subNodes: subNodes)

            batch.clearUpdates()

            #expect(!treeUpdates.isAnyUpdated)
            #expect(encodable.meshes.count == 1)
        }

        subNodes.forEach { $0.clearUpdates() }

        plane0.data.setRectColor(.init(repeating: 0.5), rectIndex: 0)

        do {
            // override

            let encodable = RenderEncodableStub()
            var renderInfo = NodeRenderInfo(encodable: encodable)
            var treeUpdates = TreeUpdates()

            batch.fetchUpdates(&treeUpdates)

            try batch.prepareForRendering(system: system)
            batch.buildRenderInfo(&renderInfo, subNodes: subNodes)

            batch.clearUpdates()

            #expect(!treeUpdates.isAnyUpdated)
            #expect(encodable.meshes.count == 1)
        }
    }
}
