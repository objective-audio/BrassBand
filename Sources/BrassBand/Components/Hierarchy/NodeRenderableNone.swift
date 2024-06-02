import Foundation

extension Node {
    final class RenderableNone: Renderable {
        init() {}
    }
}

extension Node.RenderableNone {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {}
    func prepareForRendering(system: some RenderSystem) throws {}

    func buildRenderInfo(_ renderInfo: inout NodeRenderInfo, subNodes: [some Node.SubNode]) {
        let treeMatrix = renderInfo.matrix
        let meshMatrix = renderInfo.meshMatrix

        for subNode in subNodes {
            renderInfo.matrix = treeMatrix
            renderInfo.meshMatrix = meshMatrix
            subNode.buildRenderInfo(&renderInfo)
        }
    }

    func clearUpdates() {}
}

extension Node.RenderableNone {
    protocol MetalSystem: RenderSystem {}
}

extension MetalSystem: Node.RenderableNone.MetalSystem {}
