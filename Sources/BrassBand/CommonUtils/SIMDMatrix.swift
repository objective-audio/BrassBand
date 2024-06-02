import Foundation

extension simd_float4x4 {
    public static func scaling(width: Float, height: Float) -> simd_float4x4 {
        .init(
            .init(width, 0.0, 0.0, 0.0), .init(0.0, height, 0.0, 0.0), .init(0.0, 0.0, 1.0, 0.0),
            .init(0.0, 0.0, 0.0, 1.0))
    }

    public static func scaling(scale: Size) -> simd_float4x4 {
        scaling(width: scale.width, height: scale.height)
    }

    public static func translation(x: Float, y: Float) -> simd_float4x4 {
        .init(
            .init(1.0, 0.0, 0.0, 0.0), .init(0.0, 1.0, 0.0, 0.0), .init(0.0, 0.0, 1.0, 0.0),
            .init(x, y, 0.0, 1.0))
    }

    public static func translation(position: Point) -> simd_float4x4 {
        translation(x: position.x, y: position.y)
    }

    public static func rotation(angle: Angle) -> simd_float4x4 {
        let radians = angle.radians
        let cos = cosf(radians)
        let sin = sinf(radians)

        return .init(
            .init(cos, sin, 0.0, 0.0), .init(-sin, cos, 0.0, 0.0), .init(0.0, 0.0, 1.0, 0.0),
            .init(0.0, 0.0, 0.0, 1.0))
    }

    public static func ortho(
        left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float
    )
        -> simd_float4x4
    {
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = far + near
        let fsn = far - near

        return .init(
            .init(2.0 / rsl, 0.0, 0.0, 0.0), .init(0.0, 2.0 / tsb, 0.0, 0.0),
            .init(0.0, 0.0, -2.0 / fsn, 0.0), .init(-ral / rsl, -tab / tsb, -fan / fsn, 1.0))
    }

    public var cpp: simd.float4x4 {
        .init(self)
    }
}
