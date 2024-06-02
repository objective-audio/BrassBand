import Foundation

extension Renderer {
    @MainActor
    public protocol Detector: DetectorForRenderInfo {
        func beginUpdate()
        func endUpdate()
    }

    @MainActor
    public protocol System {
        func viewRender(
            projectionMatrix: simd_float4x4, rootNode: Node, detector: any DetectorForRenderInfo)
    }

    @MainActor
    public protocol ViewLook {
        var background: Background { get }
        var projectionMatrix: simd_float4x4 { get }
    }

    public protocol Action: Sendable {
        @MainActor
        func update(_ date: Date) -> Bool
    }
}
