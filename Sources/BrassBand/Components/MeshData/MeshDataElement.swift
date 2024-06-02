import BrassBandCpp
import Foundation

public protocol MeshDataElement: ~Copyable, Sendable {}

extension Vertex2d: MeshDataElement {}
extension Index2d: MeshDataElement {}
