import Foundation

@MainActor
final class Batch {
    private enum BatchError: Error {
        case kindIsNil
    }

    private var renderMeshInfos: [BatchRenderMeshInfo] = []
    private var renderMeshes: [Mesh] = []
    private var buildingKind: BatchBuildingKind?
    private var system: (any RenderSystem)?

    init() {}
}

extension Batch: RenderEncodable {
    func appendMesh(_ mesh: Mesh) {
        guard buildingKind == .rebuild else { return }

        var (index, meshInfo) = findOrMakeMeshInfo(
            primitiveType: mesh.primitiveType, texture: mesh.texture)
        meshInfo.vertexCount += mesh.renderVertexCount
        meshInfo.indexCount += mesh.renderIndexCount
        meshInfo.sourceMeshes.append(mesh)
        renderMeshInfos[index] = meshInfo
    }
}

extension Batch {
    private func beginRenderMeshBuilding(kind: BatchBuildingKind) {
        if kind == .rebuild {
            clearRenderMeshes()
        }

        self.buildingKind = kind
    }

    private func commitRenderMeshesBuilding() throws {
        guard let buildingKind else {
            throw BatchError.kindIsNil
        }

        renderMeshInfos = renderMeshInfos.map { meshInfo in
            var meshInfo = meshInfo

            switch buildingKind {
            case .rebuild:
                meshInfo.vertexData = DynamicMeshVertexData(capacity: meshInfo.vertexCount)
                meshInfo.indexData = DynamicMeshIndexData(capacity: meshInfo.indexCount)
                meshInfo.renderMesh.vertexData = meshInfo.vertexData?.rawMeshData
                meshInfo.renderMesh.indexData = meshInfo.indexData?.rawMeshData
            case .override:
                meshInfo.vertexIndex = 0
                meshInfo.indexIndex = 0
            }

            for sourceMesh in meshInfo.sourceMeshes {
                if sourceMesh.preRender() {
                    sourceMesh.batchRender(meshInfo: &meshInfo, buildingKind: buildingKind)
                }
            }

            return meshInfo
        }

        if buildingKind == .rebuild {
            var renderMeshes: [Mesh] = []
            renderMeshes.reserveCapacity(renderMeshInfos.count)

            for meshInfo in renderMeshInfos {
                let renderMesh = meshInfo.renderMesh
                if let vertexData = renderMesh.vertexData, vertexData.count > 0,
                    let indexData = renderMesh.indexData, indexData.count > 0
                {
                    renderMeshes.append(renderMesh)
                }
            }

            self.renderMeshes = renderMeshes
        }

        if let system {
            for mesh in renderMeshes {
                try mesh.prepareForRendering(system: system)
            }
        }

        self.buildingKind = nil
    }

    private func clearRenderMeshes() {
        renderMeshes.removeAll()
        renderMeshInfos.removeAll()
    }

    private func findOrMakeMeshInfo(primitiveType: PrimitiveType, texture: Texture?)
        -> (Int, BatchRenderMeshInfo)
    {
        for (index, info) in renderMeshInfos.enumerated() {
            if info.renderMesh.primitiveType == primitiveType, info.renderMesh.texture === texture {
                return (index, info)
            }
        }

        let info = BatchRenderMeshInfo(primitiveType: primitiveType, texture: texture)

        let index = renderMeshInfos.count
        renderMeshInfos.append(info)
        return (index, info)
    }
}

extension Batch: Node.Renderable {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {}

    func prepareForRendering(system: some RenderSystem) throws {
        self.system = system
    }

    func buildRenderInfo(_ renderInfo: inout NodeRenderInfo, subNodes: [some Node.SubNode]) {
        let treeMatrix = renderInfo.matrix
        let meshMatrix = renderInfo.meshMatrix

        var treeUpdates = TreeUpdates()

        for subNode in subNodes {
            subNode.fetchUpdates(&treeUpdates)
        }

        let buildingKind = treeUpdates.batchBuildingKind

        var batchRenderInfo = NodeRenderInfo(
            detector: renderInfo.detector, encodable: nil, effectable: nil, stackable: nil)

        if let buildingKind {
            batchRenderInfo.encodable = self
            beginRenderMeshBuilding(kind: buildingKind)
        }

        for subNode in subNodes {
            batchRenderInfo.matrix = treeMatrix
            batchRenderInfo.meshMatrix = matrix_identity_float4x4
            subNode.buildRenderInfo(&batchRenderInfo)
        }

        if buildingKind != nil {
            try! commitRenderMeshesBuilding()
        }

        for mesh in renderMeshes {
            mesh.matrix = meshMatrix
            renderInfo.encodable?.appendMesh(mesh)
        }
    }

    func clearUpdates() {}
}

extension Batch {
    protocol MetalSystem: Mesh.MetalSystem {}
}

extension MetalSystem: Batch.MetalSystem {}
