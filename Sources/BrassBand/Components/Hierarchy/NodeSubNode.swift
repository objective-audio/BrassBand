import Foundation

extension Node {
    @MainActor
    protocol SubNode {
        func fetchUpdates(_ treeUpdates: inout TreeUpdates)
        func buildRenderInfo(_ renderInfo: inout NodeRenderInfo)
    }
}
