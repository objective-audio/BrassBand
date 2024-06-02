import Foundation

extension Node {
    public struct Geometry: Sendable {
        public var position: Point = .zero
        public var angle: Angle = .zero
        public var scale: Size = .one
    }
}

extension Node.Geometry {
    public var x: Float {
        get { position.x }
        set { position.x = newValue }
    }

    public var y: Float {
        get { position.y }
        set { position.y = newValue }
    }

    public var width: Float {
        get { scale.width }
        set { scale.width = newValue }
    }

    public var height: Float {
        get { scale.height }
        set { scale.height = newValue }
    }

    public var matrix: simd_float4x4 {
        simd_float4x4.translation(position: position)
            * simd_float4x4.rotation(angle: angle)
            * simd_float4x4.scaling(scale: scale)
    }
}
