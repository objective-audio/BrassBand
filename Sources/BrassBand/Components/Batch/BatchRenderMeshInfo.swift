import Foundation

@MainActor
struct BatchRenderMeshInfo {
    let renderMesh: Mesh
    var sourceMeshes: [Mesh] = []
    var vertexData: DynamicMeshVertexData?
    var indexData: DynamicMeshIndexData?

    var vertexCount: Int = 0
    var indexCount: Int = 0
    var vertexIndex: Int = 0
    var indexIndex: Int = 0

    init(primitiveType: PrimitiveType, texture: Texture?) {
        let mesh = Mesh(texture: texture, primitiveType: primitiveType)
        mesh.isMeshColorUsed = true
        renderMesh = mesh
    }
}
