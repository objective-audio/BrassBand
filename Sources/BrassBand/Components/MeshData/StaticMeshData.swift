import Foundation

public typealias StaticMeshVertexData = StaticMeshData<Vertex2d>
public typealias StaticMeshIndexData = StaticMeshData<Index2d>

@MainActor
public struct StaticMeshData<Element: MeshDataElement> {
    public let rawMeshData: MeshData<Element>

    public init(count: Int, handler: @MainActor (UnsafeMutableBufferPointer<Element>) -> Void) {
        rawMeshData = .init(capacity: count, dynamicBufferCount: 1)
        rawMeshData.write(handler)
    }

    public init(
        count: Int, handler: @Sendable @escaping (UnsafeMutableBufferPointer<Element>) -> Void
    ) async {
        rawMeshData = .init(capacity: count, dynamicBufferCount: 1)
        await rawMeshData.writeAsync(handler)
    }
}
