import Foundation
import simd

@MainActor
public final class RenderTarget {
    enum RenderTargetError: Error {
        case invalidSystemType
    }

    public let layoutGuide: LayoutRegionGuide = .init()

    public var effect: Effect = .init() {
        didSet {
            guard effect !== oldValue else { return }
            updates.insert(.effect)
            setTexturesToEffect()
        }
    }

    public private(set) var scaleFactor: Double = 0.0 {
        didSet {
            if scaleFactor != oldValue {
                sourceTexture.scaleFactor = scaleFactor
                destinationTexture.scaleFactor = scaleFactor
                updates.insert(.scaleFactor)
            }
        }
    }

    private let data: RectPlaneData = .init(rectCount: 1)
    private let sourceTexture: Texture
    private let destinationTexture: Texture
    private let mesh: Mesh
    private var renderPassDescriptor: MTLRenderPassDescriptor = .init()
    private var projectionMatrix: simd_float4x4 = matrix_identity_float4x4

    private var cancellables: Set<AnyCancellable> = []
    private var metalSystem: (any MetalSystem)?

    private var updates: RenderTargetUpdateReason = .all

    public init(scaleFactorProvider: some Texture.ScaleFactorProviding) {
        sourceTexture = .init(
            pointSize: .zero, drawPadding: 0, usage: [.renderTarget, .shaderRead],
            pixelFormat: .bgra8Unorm, scaleFactorProvider: scaleFactorProvider)
        destinationTexture = .init(
            pointSize: .zero, drawPadding: 0, usage: [.shaderWrite], pixelFormat: .bgra8Unorm,
            scaleFactorProvider: scaleFactorProvider)
        mesh = .init(
            vertexData: data.vertexData.rawMeshData, indexData: data.indexData.rawMeshData,
            texture: destinationTexture)

        setTexturesToEffect()

        sourceTexture.metalTextureDidChange.sink { [weak self] _ in
            guard let self else { return }

            if let metalTexture = self.sourceTexture.metalTexture {
                let colorDescription = MTLRenderPassColorAttachmentDescriptor()
                colorDescription.loadAction = .clear
                colorDescription.clearColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                metalTexture.setToColorDescription(colorDescription)
                self.renderPassDescriptor.colorAttachments[0] = colorDescription
            } else {
                self.renderPassDescriptor.colorAttachments[0] = nil
            }
        }.store(in: &cancellables)

        destinationTexture.sizeDidUpdate.sink { [weak self] _ in
            guard let self else { return }
            let actualSize = self.destinationTexture.actualSize
            self.data.setRectTexcoords(.init(origin: .zero, size: actualSize), rectIndex: 0)
        }.store(in: &cancellables)

        layoutGuide.regionPublisher.sink { [weak self] region in
            guard let self else { return }
            let size = UIntSize(
                width: UInt32(region.size.width), height: UInt32(region.size.height))
            self.sourceTexture.pointSize = size
            self.destinationTexture.pointSize = size

            self.projectionMatrix = simd_float4x4.ortho(
                left: region.left, right: region.right, bottom: region.bottom, top: region.top,
                near: -1.0, far: 1.0)

            self.data.setRectPosition(region, rectIndex: 0)

            self.updates.insert(.region)
        }.store(in: &cancellables)

        scaleFactorProvider.scaleFactorPublisher.sink { [weak self] scale in
            self?.scaleFactor = scale
        }.store(in: &cancellables)
    }
}

extension RenderTarget: Node.Renderable {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {
        treeUpdates.renderTargetUpdates.formUnion(updates)
        mesh.fetchUpdates(&treeUpdates)
        effect.fetchUpdates(&treeUpdates)
    }

    func prepareForRendering(system: some RenderSystem) throws {
        guard let system = system as? any MetalSystem else {
            throw RenderTargetError.invalidSystemType
        }

        metalSystem = system
        try sourceTexture.prepareForRendering(system: system)
        try destinationTexture.prepareForRendering(system: system)
        try mesh.prepareForRendering(system: system)
        try effect.prepareForRendering(system)
    }

    func buildRenderInfo(_ renderInfo: inout NodeRenderInfo, subNodes: [some Node.SubNode]) {
        let treeMatrix = renderInfo.matrix
        let meshMatrix = renderInfo.meshMatrix

        if let renderEncodable = renderInfo.encodable {
            mesh.matrix = meshMatrix
            renderEncodable.appendMesh(mesh)
        }

        var needsRender = !updates.isEmpty

        if !needsRender {
            var treeUpdates = TreeUpdates()

            for subNode in subNodes {
                subNode.fetchUpdates(&treeUpdates)
            }

            needsRender = treeUpdates.isAnyUpdated
        }

        if needsRender, let stackable = renderInfo.stackable,
            pushEncodeInfo(encoder: stackable)
        {
            var targetRenderInfo = NodeRenderInfo(
                detector: renderInfo.detector, encodable: renderInfo.encodable,
                effectable: renderInfo.effectable, stackable: stackable)

            let projectionMatrix = projectionMatrix
            let matrix = projectionMatrix * treeMatrix
            let meshMatrix = projectionMatrix

            for subNode in subNodes {
                targetRenderInfo.matrix = matrix
                targetRenderInfo.meshMatrix = meshMatrix
                subNode.buildRenderInfo(&targetRenderInfo)
            }

            renderInfo.effectable?.appendEffect(effect)

            stackable.popEncodeInfo()
        }
    }

    func clearUpdates() {
        updates = []
        mesh.clearUpdates()
        effect.clearUpdates()
    }
}

extension RenderTarget {
    private func pushEncodeInfo(encoder: any RenderStackable) -> Bool {
        guard isSizeEnough, let metalSystem else {
            return false
        }
        metalSystem.pushEncodeInfo(renderPassDescriptor: renderPassDescriptor, encoder: encoder)
        return true
    }

    private func setTexturesToEffect() {
        effect.set(sourceTexture: sourceTexture, destinationTexture: destinationTexture)
    }

    private var isSizeEnough: Bool {
        let actualSize = destinationTexture.actualSize
        return actualSize.width > 0 && actualSize.height > 0
    }
}

extension Node {
    public struct RenderTargetContainer: Sendable {
        public let node: Node
        public let renderTarget: RenderTarget

        @MainActor
        public init(scaleFactorProvider provider: some Texture.ScaleFactorProviding) {
            renderTarget = RenderTarget(scaleFactorProvider: provider)
            node = Node(renderTarget: renderTarget)
        }
    }
}

extension RenderTarget {
    protocol MetalSystem: Texture.MetalSystem, Mesh.MetalSystem {
        func pushEncodeInfo(
            renderPassDescriptor: MTLRenderPassDescriptor, encoder: any RenderStackable)
    }
}

extension MetalSystem: RenderTarget.MetalSystem {}
