import Foundation

@MainActor
public final class RectPlane {
    private let container = Node.ContentContainer()
    public var node: Node { container.node }
    public var content: Node.Content { container.content }
    public let data: RectPlaneData

    public init(data: RectPlaneData) {
        self.data = data

        let mesh = Mesh(
            vertexData: data.vertexData.rawMeshData, indexData: data.indexData.rawMeshData)
        container.content.meshes = [mesh]
    }

    convenience public init(rectCount: Int) {
        self.init(data: .init(rectCount: rectCount, indexCount: rectCount))
    }

    convenience public init(rectCount: Int, indexCount: Int) {
        self.init(data: .init(rectCount: rectCount, indexCount: indexCount))
    }
}
