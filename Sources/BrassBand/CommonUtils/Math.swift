import Foundation

public func round(_ value: Double, scale: Double) -> Double {
    round(scale * value) / scale
}

public func round(_ value: Float, scale: Double) -> Float {
    Float(round(Double(value), scale: scale))
}

public func ceil(_ value: Double, scale: Double) -> Double {
    ceil(scale * value) / scale
}

public func ceil(_ value: Float, scale: Double) -> Float {
    Float(ceil(Double(value), scale: scale))
}

public func clampZeroToOne(_ value: Float) -> Float {
    if value < 0.0 {
        return 0.0
    } else if value > 1.0 {
        return 1.0
    } else {
        return value
    }
}
