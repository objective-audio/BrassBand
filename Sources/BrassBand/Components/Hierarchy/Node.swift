import Foundation
import simd

@MainActor
public final class Node {
    @MainActor
    protocol Renderable: Sendable {
        func fetchUpdates(_ treeUpdates: inout TreeUpdates)
        func prepareForRendering(system: some RenderSystem) throws
        func buildRenderInfo(
            _ renderInfo: inout NodeRenderInfo, subNodes: [some Node.SubNode])
        func clearUpdates()
    }

    let renderable: any Renderable
    public var content: Content? { renderable as? Content }
    var batch: Batch? { renderable as? Batch }
    public var renderTarget: RenderTarget? { renderable as? RenderTarget }

    public internal(set) weak var parent: (any Node.Parent)?

    public private(set) var subNodes: [Node] = [] {
        didSet { updates.insert(.hierarchy) }
    }

    public var geometry: Geometry = .init() {
        didSet {
            needsUpdateLocalMatrix = true
            updates.insert(.geometry)
        }
    }

    private var _localMatrix: simd_float4x4 = matrix_identity_float4x4

    private var localMatrix: simd_float4x4 {
        if needsUpdateLocalMatrix {
            _localMatrix = geometry.matrix
            needsUpdateLocalMatrix = false
        }
        return _localMatrix
    }

    @CurrentValue
    public var isEnabled: Bool = true {
        didSet { updates.insert(.enabled) }
    }
    public var isEnabledPublisher: AnyPublisher<Bool, Never> {
        $isEnabled.eraseToAnyPublisher()
    }

    @CurrentValue
    public var colliders: [Collider] = [] {
        didSet { updates.insert(.collider) }
    }
    public var collidersPublisher: AnyPublisher<[Collider], Never> {
        $colliders.eraseToAnyPublisher()
    }

    private var updates: NodeUpdateReason = []
    private var needsUpdateLocalMatrix: Bool = true
    private var isBuildingRenderInfo: Bool = false

    init(renderable: any Renderable) {
        self.renderable = renderable
    }

    init(parent: some Node.Parent) {
        self.renderable = RenderableNone()
        self.parent = parent
    }

    convenience public init() {
        self.init(renderable: RenderableNone())
    }

    convenience public init(renderTarget: RenderTarget) {
        self.init(renderable: renderTarget)
    }

    public static var content: Node { .init(renderable: Content()) }
    public static var batch: Node { .init(renderable: Batch()) }
    public static func renderTarget(scaleFactorProvider: some Texture.ScaleFactorProviding) -> Node
    {
        .init(renderable: RenderTarget(scaleFactorProvider: scaleFactorProvider))
    }
}

extension Node {
    public func appendSubNode(_ subNode: Node) {
        insertSubNode(subNode, at: subNodes.count)
    }

    public func insertSubNode(_ subNode: Node, at index: Int) {
        subNode.removeFromSuper()
        subNode.parent = self
        subNodes.insert(subNode, at: index)
    }

    public func removeSubNode(at index: Int) {
        guard index < subNodes.count else { return }
        subNodes[index].removeFromSuper()
    }

    public func removeAllSubNodes() {
        guard !subNodes.isEmpty else { return }

        for subNode in subNodes {
            subNode.parent = nil
        }

        subNodes.removeAll()
    }

    public func removeFromSuper() {
        parent?.removeSubNode(self)
    }

    public func removeSubNode(_ subNode: Node) {
        guard subNodes.contains(where: { $0 === subNode }) else {
            return
        }
        subNode.parent = nil
        subNodes.removeAll { $0 === subNode }
    }
}

extension Node: Node.Parent {
    public var treeMatrix: simd_float4x4 {
        precondition(!isBuildingRenderInfo)
        let parentMatrix: simd_float4x4 = parent?.treeMatrix ?? matrix_identity_float4x4
        return parentMatrix * localMatrix
    }
}

extension Node: Node.SubNode {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {
        if isEnabled {
            treeUpdates.nodeUpdates.formUnion(updates)

            renderable.fetchUpdates(&treeUpdates)

            for subNode in subNodes {
                subNode.fetchUpdates(&treeUpdates)
            }
        } else if updates.contains(.enabled) {
            treeUpdates.nodeUpdates.insert(.enabled)
        }
    }

    func prepareForRendering(system: some RenderSystem) throws {
        try renderable.prepareForRendering(system: system)

        for subNode in subNodes {
            try subNode.prepareForRendering(system: system)
        }
    }

    func buildRenderInfo(_ renderInfo: inout NodeRenderInfo) {
        guard isEnabled else { return }

        isBuildingRenderInfo = true
        defer { isBuildingRenderInfo = false }

        let localMatrix = self.localMatrix
        let treeMatrix = renderInfo.matrix * localMatrix
        let meshMatrix = renderInfo.meshMatrix * localMatrix

        renderInfo.matrix = treeMatrix
        renderInfo.meshMatrix = meshMatrix

        for collider in colliders {
            collider.matrix = treeMatrix
        }

        if let detector = renderInfo.detector, detector.isUpdating {
            for collider in colliders {
                detector.add(collider: collider)
            }
        }

        renderable.buildRenderInfo(&renderInfo, subNodes: subNodes)
    }

    func clearUpdates() {
        if isEnabled {
            updates = []

            renderable.clearUpdates()

            for subNode in self.subNodes {
                subNode.clearUpdates()
            }
        } else {
            updates.remove(.enabled)
        }
    }
}
