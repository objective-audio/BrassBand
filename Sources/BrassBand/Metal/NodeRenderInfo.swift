import Foundation

public struct NodeRenderInfo {
    var matrix: simd_float4x4 = matrix_identity_float4x4
    var meshMatrix: simd_float4x4 = matrix_identity_float4x4
    var detector: (any DetectorForRenderInfo)?
    var encodable: (any RenderEncodable)?
    var effectable: (any RenderEffectable)?
    var stackable: (any RenderStackable)?
}
