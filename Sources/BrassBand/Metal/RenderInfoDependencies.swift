import Foundation

@MainActor
protocol RenderEncodable: AnyObject {
    func appendMesh(_ mesh: Mesh)
}

@MainActor
protocol RenderEffectable: AnyObject {
    func appendEffect(_ effect: Effect)
}

@MainActor
protocol RenderStackable: AnyObject {
    func pushEncodeInfo(_ info: MetalEncodeInfo)
    func popEncodeInfo()
    var currentEncodeInfo: MetalEncodeInfo? { get }
}

@MainActor
public protocol DetectorForRenderInfo: AnyObject {
    var isUpdating: Bool { get }
    func add(collider: Collider)
}
