import Testing

@testable import BrassBand

@MainActor
struct NodeRenderableTests {
    @Test func none() {
        let node = Node()

        #expect(node.renderable is Node.RenderableNone)
        #expect(node.content == nil)
        #expect(node.renderTarget == nil)
        #expect(node.batch == nil)
    }

    @Test func content() {
        let node = Node.content

        #expect(node.renderable is Node.Content)
        #expect(node.content != nil)
        #expect(node.renderTarget == nil)
        #expect(node.batch == nil)
    }

    @Test func batch() {
        let node = Node.batch

        #expect(node.renderable is Batch)
        #expect(node.content == nil)
        #expect(node.renderTarget == nil)
        #expect(node.batch != nil)
    }

    @Test func renderTarget() {
        let node = Node.renderTarget(scaleFactorProvider: ProviderStub())

        #expect(node.renderable is RenderTarget)
        #expect(node.content == nil)
        #expect(node.renderTarget != nil)
        #expect(node.batch == nil)
    }
}

private struct ProviderStub: Texture.ScaleFactorProviding {
    var scaleFactor: Double { 1.0 }
    var scaleFactorPublisher: AnyPublisher<Double, Never> {
        Just(1.0).eraseToAnyPublisher()
    }
}
