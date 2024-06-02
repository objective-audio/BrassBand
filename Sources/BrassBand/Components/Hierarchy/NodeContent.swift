import Foundation

extension Node {
    public final class Content: Renderable {
        enum NodeContentError: Error {
            case invalidSystemType
        }

        public var color: Color {
            didSet {
                updateMeshColor()
            }
        }
        public var meshes: [Mesh] {
            didSet {
                updateMeshColor()
                updates.insert(.mesh)
            }
        }

        var updates: NodeUpdateReason = []

        init(meshes: [Mesh] = [], color: Color = .init(repeating: 1.0)) {
            self.meshes = meshes
            self.color = color
        }
    }
}

extension Node.Content {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {
        treeUpdates.nodeUpdates.formUnion(updates)

        for mesh in meshes {
            mesh.fetchUpdates(&treeUpdates)
        }
    }

    func prepareForRendering(system: some RenderSystem) throws {
        guard let system = system as? any MetalSystem else {
            throw NodeContentError.invalidSystemType
        }

        for mesh in meshes {
            try mesh.prepareForRendering(system: system)
        }
    }

    func buildRenderInfo(_ renderInfo: inout NodeRenderInfo, subNodes: [some Node.SubNode]) {
        let treeMatrix = renderInfo.matrix
        let meshMatrix = renderInfo.meshMatrix

        if let renderEncodable = renderInfo.encodable {
            for mesh in meshes {
                mesh.matrix = meshMatrix
                renderEncodable.appendMesh(mesh)
            }
        }

        for subNode in subNodes {
            renderInfo.matrix = treeMatrix
            renderInfo.meshMatrix = meshMatrix
            subNode.buildRenderInfo(&renderInfo)
        }
    }

    func clearUpdates() {
        updates = []

        for mesh in meshes {
            mesh.clearUpdates()
        }
    }
}

extension Node.Content {
    private func updateMeshColor() {
        for mesh in meshes {
            mesh.color = color
        }
    }
}

extension Node {
    public struct ContentContainer: Sendable {
        public let node: Node
        public let content: Content

        @MainActor
        public init(meshes: [Mesh] = [], color: Color = .init(repeating: 1.0)) {
            content = Content(meshes: meshes, color: color)
            node = Node(renderable: content)
        }
    }
}

extension Node.Content {
    protocol MetalSystem: Mesh.MetalSystem {}
}

extension MetalSystem: Node.Content.MetalSystem {}
