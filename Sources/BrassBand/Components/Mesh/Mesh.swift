import Foundation
import simd

@MainActor
public final class Mesh {
    var vertexData: MeshData<Vertex2d>? {
        didSet {
            if vertexData !== oldValue {
                updates.insert(.vertexData)
            }
        }
    }
    var indexData: MeshData<Index2d>? {
        didSet {
            if indexData !== oldValue {
                updates.insert(.indexData)
            }
        }
    }

    public var texture: Texture? {
        didSet {
            if texture !== oldValue, isMeshDataExists {
                updates.insert(.texture)
            }
        }
    }

    public var color: Color {
        didSet {
            if color != oldValue, isMeshDataExists, !isMeshColorUsed {
                updates.insert(.color)
            }
        }
    }
    public var isMeshColorUsed: Bool {
        didSet {
            if isMeshColorUsed != oldValue, isMeshDataExists {
                updates.insert(.meshColorUsed)
            }
        }
    }
    public var primitiveType: PrimitiveType {
        didSet {
            if primitiveType != oldValue, isMeshDataExists {
                updates.insert(.primitiveType)
            }
        }
    }

    var matrix: simd_float4x4 = matrix_identity_float4x4 {
        didSet {
            if matrix != oldValue, isRenderingColorExists {
                updates.insert(.matrix)
            }
        }
    }

    private var updates: MeshUpdateReason = .all

    private var isMeshDataExists: Bool {
        if let vertexData, vertexData.count > 0, let indexData, indexData.count > 0 {
            return true
        } else {
            return false
        }
    }

    public init(
        vertexData: MeshData<Vertex2d>? = nil, indexData: MeshData<Index2d>? = nil,
        texture: Texture? = nil, color: Color = .init(repeating: 1.0),
        isMeshColorUsed: Bool = false, primitiveType: PrimitiveType = .triangle
    ) {
        self.vertexData = vertexData
        self.indexData = indexData
        self.texture = texture
        self.color = color
        self.isMeshColorUsed = isMeshColorUsed
        self.primitiveType = primitiveType
    }
}

// for normal rendering

extension Mesh {
    private var isRenderingColorExists: Bool { isMeshDataExists }

    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {
        treeUpdates.meshUpdates.formUnion(updates)
        vertexData?.fetchUpdates(&treeUpdates.vertexDataUpdates)
        indexData?.fetchUpdates(&treeUpdates.indexDataUpdates)
    }

    func prepareForRendering(system: some RenderSystem) throws {
        try vertexData?.prepareForRendering(system: system)
        try indexData?.prepareForRendering(system: system)
        try texture?.prepareForRendering(system: system)
    }

    func preRender() -> Bool {
        if let vertexData, let indexData {
            vertexData.updateRenderBuffer()
            indexData.updateRenderBuffer()
            return isRenderingColorExists
        } else {
            return false
        }
    }

    func encode(
        encoder: any MTLRenderCommandEncoder, encodeInfo: MetalEncodeInfo,
        currentUniformsBuffer: any MTLBuffer,
        uniformsBufferOffset: Int
    ) {
        if let texture {
            encoder.setRenderPipelineState(encodeInfo.pipelineStateWithTexture)
            encoder.setFragmentBuffer(texture.metalTexture?.argumentBuffer.mtl, offset: 0, index: 0)
        } else {
            encoder.setRenderPipelineState(encodeInfo.pipelineStateWithoutTexture)
        }

        guard let vertexData, let indexData,
            let vertexMetalBuffer = vertexData.metalBuffer,
            let indexMetalBuffer = indexData.metalBuffer
        else { return }

        encoder.setVertexBuffer(
            vertexMetalBuffer.mtl, offset: vertexData.byteOffset, index: 0)
        encoder.setVertexBuffer(currentUniformsBuffer, offset: uniformsBufferOffset, index: 1)

        encoder.drawIndexedPrimitives(
            type: primitiveType.mtl, indexCount: indexData.count, indexType: .uint32,
            indexBuffer: indexMetalBuffer.mtl, indexBufferOffset: indexData.byteOffset)
    }

    func clearUpdates() {
        updates = []
        vertexData?.clearUpdates()
        indexData?.clearUpdates()
    }
}

// for batch rendering

extension Mesh {
    var renderVertexCount: Int {
        if isRenderingColorExists, let vertexData, indexData != nil {
            return vertexData.count
        } else {
            return 0
        }
    }

    var renderIndexCount: Int {
        if isRenderingColorExists, vertexData != nil, let indexData {
            return indexData.count
        } else {
            return 0
        }
    }

    func batchRender(meshInfo: inout BatchRenderMeshInfo, buildingKind: BatchBuildingKind) {
        let nextVertexIndex = meshInfo.vertexIndex + (vertexData?.count ?? 0)
        let nextIndexIndex = meshInfo.indexIndex + (indexData?.count ?? 0)

        assert(nextVertexIndex <= meshInfo.vertexCount)
        assert(nextIndexIndex <= meshInfo.indexCount)

        if needsWrite(buildingKind: buildingKind) {
            let destinationVertexOffset = meshInfo.vertexIndex

            if let sourceVertexData = vertexData {
                meshInfo.vertexData?.write { destinationBuffer in
                    sourceVertexData.read {
                        (sourceBuffer: UnsafeBufferPointer<Vertex2d>) in
                        for index in 0..<sourceVertexData.count {
                            let sourceVertex = sourceBuffer[index]
                            let destinationIndex = destinationVertexOffset + index

                            destinationBuffer[destinationIndex].position =
                                (matrix * sourceVertex.position.simd4).simd2
                            destinationBuffer[destinationIndex].texCoord = sourceVertex.texCoord
                            destinationBuffer[destinationIndex].color =
                                isMeshColorUsed ? (sourceVertex.color * color.simd4) : color.simd4
                        }
                    }
                }
            }

            if let sourceIndexData = indexData {
                meshInfo.indexData?.write { destinationBuffer in
                    let destinationIndexOffset = meshInfo.indexIndex
                    sourceIndexData.read { (sourceBuffer: UnsafeBufferPointer<Index2d>) in
                        for index in 0..<sourceIndexData.count {
                            let destinationIndex = destinationIndexOffset + index

                            destinationBuffer[destinationIndex] =
                                sourceBuffer[index] + Index2d(destinationVertexOffset)
                        }
                    }
                }
            }
        }

        meshInfo.vertexIndex = nextVertexIndex
        meshInfo.indexIndex = nextIndexIndex
    }

    private func needsWrite(buildingKind: BatchBuildingKind) -> Bool {
        switch buildingKind {
        case .rebuild:
            return true
        case .override:
            if updates.andTest([.color, .meshColorUsed, .matrix]) {
                return true
            }

            if let vertexData {
                var outUpdates: MeshDataUpdateReason = []
                vertexData.fetchUpdates(&outUpdates)
                if outUpdates.contains(.dataContent) {
                    return true
                }
            }

            // TODO: indexDataが変わることがないなら不要かも
            if let indexData {
                var outUpdates: MeshDataUpdateReason = []
                indexData.fetchUpdates(&outUpdates)
                if outUpdates.contains(.dataContent) {
                    return true
                }
            }

            return false
        }
    }
}

extension Mesh {
    @MainActor
    protocol MetalSystem: MeshDataMetalSystem, Texture.MetalSystem {}
}

extension MetalSystem: Mesh.MetalSystem {}
