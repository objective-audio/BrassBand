import Foundation

extension Node {
    @MainActor
    public protocol Parent: AnyObject {
        var treeMatrix: simd_float4x4 { get }
        func removeSubNode(_ subNode: Node)
    }
}

extension Node.Parent {
    public func convertPosition(_ position: Point) -> Point {
        let location = treeMatrix.inverse * position.simd2.simd4
        return .init(simd2: location.simd2)
    }
}
