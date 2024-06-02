import Foundation

public typealias DynamicMeshVertexData = DynamicMeshData<Vertex2d>
public typealias DynamicMeshIndexData = DynamicMeshData<Index2d>

@MainActor
public struct DynamicMeshData<Element: MeshDataElement> {
    public let rawMeshData: MeshData<Element>

    public init(capacity: Int, count: Int? = nil) {
        self.rawMeshData = .init(capacity: capacity, count: count, dynamicBufferCount: 2)
    }

    public func read(_ handler: @MainActor (UnsafeBufferPointer<Element>) -> Void) {
        rawMeshData.read(handler)
    }

    public func write(_ handler: @MainActor (UnsafeMutableBufferPointer<Element>) -> Void) {
        rawMeshData.write(handler)
    }

    public func writeAsync(
        _ handler: @Sendable @escaping (UnsafeMutableBufferPointer<Element>) -> Void
    ) async {
        await rawMeshData.writeAsync(handler)
    }
}
