import Foundation

extension RgbColor: @retroactive Equatable {}

public func * (lhs: RgbColor, rhs: RgbColor) -> RgbColor {
    .init(red: lhs.red * rhs.red, green: lhs.green * rhs.green, blue: lhs.blue * rhs.blue)
}

public func * (lhs: RgbColor, rhs: Float) -> RgbColor {
    .init(red: lhs.red * rhs, green: lhs.green * rhs, blue: lhs.blue * rhs)
}

extension RgbColor {
    public var red: Float {
        get { simd3[0] }
        set { simd3[0] = newValue }
    }

    public var green: Float {
        get { simd3[1] }
        set { simd3[1] = newValue }
    }

    public var blue: Float {
        get { simd3[2] }
        set { simd3[2] = newValue }
    }

    public init(red: Float, green: Float, blue: Float) {
        self.init(simd3: .init(red, green, blue))
    }

    public init(repeating value: Float) {
        self.init(simd3: .init(value, value, value))
    }

    public static let white: RgbColor = .init(red: 1.0, green: 1.0, blue: 1.0)
    public static let gray: RgbColor = .init(red: 0.5, green: 0.5, blue: 0.5)
    public static let darkGray: RgbColor = .init(red: 0.333, green: 0.333, blue: 0.333)
    public static let lightGray: RgbColor = .init(red: 0.667, green: 0.667, blue: 0.667)
    public static let black: RgbColor = .init(red: 0.0, green: 0.0, blue: 0.0)
    public static let red: RgbColor = .init(red: 1.0, green: 0.0, blue: 0.0)
    public static let green: RgbColor = .init(red: 0.0, green: 1.0, blue: 0.0)
    public static let blue: RgbColor = .init(red: 0.0, green: 0.0, blue: 1.0)
    public static let cyan: RgbColor = .init(red: 0.0, green: 1.0, blue: 1.0)
    public static let yellow: RgbColor = .init(red: 1.0, green: 1.0, blue: 0.0)
    public static let magenta: RgbColor = .init(red: 1.0, green: 0.0, blue: 1.0)
    public static let orange: RgbColor = .init(red: 1.0, green: 0.5, blue: 0.0)
    public static let purple: RgbColor = .init(red: 0.5, green: 0.0, blue: 0.5)
    public static let brown: RgbColor = .init(red: 0.6, green: 0.4, blue: 0.2)

    public static func hsb(hue: Float, saturation: Float, brightness: Float) -> RgbColor {
        let hueTimesSix = clampZeroToOne(hue) * 6.0
        let hueFraction = hueTimesSix - floorf(hueTimesSix)
        let intHue = Int(hueTimesSix) % 6
        let clampedSturation = clampZeroToOne(saturation)

        let max = clampZeroToOne(brightness)
        let min = max * (1.0 - clampedSturation)
        let fraction = (intHue % 2) != 0 ? (1.0 - hueFraction) : hueFraction
        let interpolation = min + (max - min) * fraction

        switch intHue {
        case 0:
            return .init(red: max, green: interpolation, blue: min)
        case 1:
            return .init(red: interpolation, green: max, blue: min)
        case 2:
            return .init(red: min, green: max, blue: interpolation)
        case 3:
            return .init(red: min, green: interpolation, blue: max)
        case 4:
            return .init(red: interpolation, green: min, blue: max)
        case 5:
            return .init(red: max, green: min, blue: interpolation)
        default:
            fatalError()
        }
    }

    public static func hsl(hue: Float, saturation: Float, lightness: Float) -> RgbColor {
        let hueTimesSix = clampZeroToOne(hue) * 6
        let hueFraction = hueTimesSix - floorf(hueTimesSix)
        let intHue = Int(hueTimesSix) % 6
        let clampedSaturation = clampZeroToOne(saturation)
        let clampedLightness = clampZeroToOne(lightness)

        let abs = abs(2.0 * clampedLightness - 1.0)
        let diff = clampedSaturation * (1.0 - abs) * 0.5
        let max = clampedLightness + diff
        let min = clampedLightness - diff

        let fraction = (intHue % 2) != 0 ? (1.0 - hueFraction) : hueFraction
        let interpolation = min + (max - min) * fraction

        switch intHue {
        case 0:
            return .init(red: max, green: interpolation, blue: min)
        case 1:
            return .init(red: interpolation, green: max, blue: min)
        case 2:
            return .init(red: min, green: max, blue: interpolation)
        case 3:
            return .init(red: min, green: interpolation, blue: max)
        case 4:
            return .init(red: interpolation, green: min, blue: max)
        case 5:
            return .init(red: max, green: min, blue: interpolation)
        default:
            fatalError()
        }
    }
}
