import Foundation
import simd

@MainActor
public final class RectPlaneData {
    public let vertexData: DynamicMeshVertexData
    public let indexData: DynamicMeshIndexData

    public init(vertexData: DynamicMeshVertexData, indexData: DynamicMeshIndexData) {
        self.vertexData = vertexData
        self.indexData = indexData
    }

    convenience public init(rectCount: Int, indexCount: Int) {
        self.init(
            vertexData: .init(capacity: rectCount * 4), indexData: .init(capacity: rectCount * 6))

        writeIndices {
            let minCount = min(rectCount, indexCount)
            for index in 0..<minCount {
                $0[index].setAll(first: Index2d(index * 4))
            }
        }
    }

    convenience public init(rectCount: Int) {
        self.init(rectCount: rectCount, indexCount: rectCount)
    }

    public var maxRectCount: Int {
        let maxIndexCount = indexData.rawMeshData.capacity
        if maxIndexCount > 0 {
            return maxIndexCount / 6
        } else {
            return 0
        }
    }

    public var rectCount: Int {
        get {
            let indexCount = indexData.rawMeshData.count
            if indexCount > 0 {
                return indexCount / 6
            } else {
                return 0
            }
        }
        set {
            indexData.rawMeshData.count = newValue * 6
        }
    }

    public func writeVertices(
        _ handler: @Sendable (UnsafeMutableBufferPointer<Vertex2dRect>) -> Void
    ) {
        vertexData.write {
            $0.withMemoryRebound(to: Vertex2dRect.self) {
                handler($0)
            }
        }
    }

    public func writeVerticesAsync(
        _ handler: @Sendable @escaping (UnsafeMutableBufferPointer<Vertex2dRect>) -> Void
    ) async {
        await vertexData.writeAsync {
            $0.withMemoryRebound(to: Vertex2dRect.self) {
                handler($0)
            }
        }
    }

    public func writeIndices(_ handler: @Sendable (UnsafeMutableBufferPointer<Index2dRect>) -> Void)
    {
        indexData.write {
            $0.withMemoryRebound(to: Index2dRect.self) {
                handler($0)
            }
        }
    }

    public func writeIndicesAsync(
        _ handler: @Sendable @escaping (UnsafeMutableBufferPointer<Index2dRect>) -> Void
    ) async {
        await indexData.writeAsync {
            $0.withMemoryRebound(to: Index2dRect.self) {
                handler($0)
            }
        }
    }

    public typealias IndexPair = (indexIndex: Int, vertexIndex: Int)
    public func setRectIndices(_ indexPairs: [IndexPair]) {
        writeIndices {
            for indexPair in indexPairs {
                $0[indexPair.indexIndex].setAll(first: UInt32(indexPair.vertexIndex * 4))
            }
        }
    }

    public func setRectPosition(
        _ region: Region, rectIndex: Int, matrix: simd_float4x4 = matrix_identity_float4x4
    ) {
        writeVertices {
            $0[rectIndex].setPositions(region.positions.applied(matrix: matrix))
        }
    }

    public func setRectColor(_ color: Color, rectIndex: Int) {
        writeVertices {
            $0[rectIndex].setColors(color.simd4)
        }
    }

    public func setRectTexcoords(_ pixelRegion: UIntRegion, rectIndex: Int) {
        writeVertices {
            $0[rectIndex].setTexCoords(pixelRegion.positions)
        }
    }

    public func setRect(
        _ rect: Vertex2dRect, rectIndex: Int, matrix: simd_float4x4 = matrix_identity_float4x4
    ) {
        writeVertices {
            $0[rectIndex] = rect.appliedToPositions(matrix: matrix)
        }
    }

    public func bindRectTexcoords(
        element: TextureElement,
        rectIndex: Int,
        transform: ((UIntRegion) -> UIntRegion)? = nil
    ) -> AnyCancellable {
        element.$texCoords.sink { [weak self] texCoords in
            let transformedCoords = transform?(texCoords) ?? texCoords
            self?.setRectTexcoords(transformedCoords, rectIndex: rectIndex)
        }
    }
}
