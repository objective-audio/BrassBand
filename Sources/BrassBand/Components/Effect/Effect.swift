import Foundation
import MetalPerformanceShaders

@MainActor
public final class Effect {
    enum Error: Swift.Error {
        case systemNotFound
        case texturesNotFound
    }

    @MainActor
    protocol Encodable {
        func encode(
            sourceTexture: Texture, destinationTexture: Texture, system: any RenderSystem,
            commandBuffer: any CommandBuffer) throws
    }

    private var sourceTexture: Texture?
    private var destinationTexture: Texture?
    private var system: (any RenderSystem)?
    private var updates: EffectUpdateReason = .all

    var encoder: (any Encodable) {
        didSet { updates.insert(.encodable) }
    }

    public convenience init() {
        self.init(encodable: Effect.throughEncoder)
    }

    init(encodable: any Encodable) {
        self.encoder = encodable
    }
}

// for RenderTarget

extension Effect {
    func set(sourceTexture: Texture, destinationTexture: Texture) {
        self.sourceTexture = sourceTexture
        self.destinationTexture = destinationTexture
        updates.insert(.textures)
    }
}

// for Rendering

extension Effect {
    func fetchUpdates(_ treeUpdates: inout TreeUpdates) {
        treeUpdates.effectUpdates.formUnion(updates)
    }

    func prepareForRendering(_ system: some RenderSystem) throws {
        self.system = system
    }

    func encode(_ commandBuffer: any CommandBuffer) throws {
        guard let system else {
            throw Error.systemNotFound
        }

        guard let sourceTexture, let destinationTexture else {
            throw Error.texturesNotFound
        }

        try encoder.encode(
            sourceTexture: sourceTexture, destinationTexture: destinationTexture,
            system: system, commandBuffer: commandBuffer)
    }

    func clearUpdates() {
        updates = []
    }

    var needsRender: Bool {
        !updates.isEmpty
    }
}
