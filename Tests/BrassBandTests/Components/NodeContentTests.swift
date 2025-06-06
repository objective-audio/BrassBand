import Testing

@testable import BrassBand

private struct EmptySystemStub: RenderSystem {}

private final class RenderEncodableStub: RenderEncodable {
    var meshes: [Mesh] = []

    func appendMesh(_ mesh: Mesh) {
        meshes.append(mesh)
    }
}

@MainActor
struct NodeContentTests {
    @Test func meshes() {
        let content = Node.Content()

        #expect(content.meshes.isEmpty)

        let meshA = Mesh()
        let meshB = Mesh()

        content.meshes = [meshA, meshB]

        #expect(content.meshes.count == 2)
        #expect(content.meshes[0] === meshA)
        #expect(content.meshes[1] === meshB)
    }

    @Test func rgbColor() {
        let content = Node.Content()

        #expect(content.color.rgb == .white)

        content.color.rgb = .black

        #expect(content.color.rgb == .black)
    }

    @Test func alpha() {
        let content = Node.Content()

        #expect(content.color.alpha.value == 1.0)

        content.color.alpha = .init(value: 0.0)

        #expect(content.color.alpha.value == 0.0)
    }

    @Test func color() {
        let content = Node.Content()

        #expect(content.color == .init(rgb: .white, alpha: .one))

        content.color = .init(rgb: .black, alpha: .zero)

        #expect(content.color == .init(rgb: .black, alpha: .zero))
    }

    @Test(.enabled(if: isMetalSystemAvailable))
    func render() throws {
        // テスト用のメッシュとコンテンツを準備
        let meshA = Mesh()
        let meshB = Mesh()
        let content = Node.Content(
            meshes: [meshA, meshB], color: .init(rgb: .blue, alpha: .init(value: 0.5)))

        // 初期状態ではupdatesは空
        #expect(content.updates.isEmpty)

        // fetchUpdatesのテスト
        var treeUpdates = TreeUpdates()
        content.fetchUpdates(&treeUpdates)

        // 特に更新がないのでTreeUpdatesも空のまま
        #expect(treeUpdates.nodeUpdates.isEmpty)

        // メッシュを変更すると更新が必要になる
        content.meshes = [meshA]

        treeUpdates = TreeUpdates()
        content.fetchUpdates(&treeUpdates)

        // メッシュの変更が検出される
        #expect(treeUpdates.nodeUpdates.contains(.mesh))

        // 正しいシステムタイプでprepareForRenderingを実行
        let device = try #require(MTLCreateSystemDefaultDevice())
        let view = MetalView()
        let system = try #require(MetalSystem(device: device, view: view))

        try content.prepareForRendering(system: system)

        // buildRenderInfoのテスト
        let translatedMatrix = simd_float4x4.translation(x: 1.0, y: 2.0)
        let scaledMatrix = simd_float4x4.scaling(scale: .init(width: 3.0, height: 4.0))

        let encodable = RenderEncodableStub()
        var renderInfo = NodeRenderInfo(encodable: encodable)
        renderInfo.matrix = translatedMatrix
        renderInfo.meshMatrix = scaledMatrix

        let subNodes: [Node] = [Node.empty, Node.empty]

        content.buildRenderInfo(&renderInfo, subNodes: subNodes)

        // メッシュが正しくエンコーダーに追加されたことを確認
        #expect(encodable.meshes.count == 1)
        #expect(encodable.meshes[0] === meshA)

        // メッシュに正しく行列が設定されたことを確認
        #expect(meshA.matrix == scaledMatrix)

        // clearUpdatesのテスト
        content.clearUpdates()

        #expect(content.updates.isEmpty)

        // メッシュの色が親コンテンツの色と同期していることを確認
        #expect(meshA.color == content.color)
    }

    @Test func renderWithInvalidSystem() throws {
        let content = Node.Content()

        // 無効なシステムタイプでprepareForRenderingを実行すると例外が発生
        #expect(throws: Node.Content.NodeContentError.invalidSystemType) {
            try content.prepareForRendering(system: EmptySystemStub())
        }
    }
}
