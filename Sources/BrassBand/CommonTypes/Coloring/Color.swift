import Foundation

extension Color: @retroactive Equatable {}

extension Color {
    public var red: Float {
        get { simd4[0] }
        set { simd4[0] = newValue }
    }

    public var green: Float {
        get { simd4[1] }
        set { simd4[1] = newValue }
    }

    public var blue: Float {
        get { simd4[2] }
        set { simd4[2] = newValue }
    }

    public var alpha: Alpha {
        get { .init(value: simd4[3]) }
        set { simd4[3] = newValue.value }
    }

    public var rgb: RgbColor {
        get { .init(red: simd4[0], green: simd4[1], blue: simd4[2]) }
        set {
            red = newValue.red
            green = newValue.green
            blue = newValue.blue
        }
    }

    public init(repeating value: Float) {
        self.init(red: value, green: value, blue: value, alpha: value)
    }

    public init(rgb: RgbColor, alpha: Alpha = .one) {
        self = .init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha.value)
    }

    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self = .init(simd4: .init(red, green, blue, alpha))
    }
}
