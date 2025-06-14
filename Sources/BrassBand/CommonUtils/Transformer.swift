import Foundation

private let curveFrames = 256

private func makeCurve(_ handler: @Sendable (Float) -> Float) -> [Float] {
    let count = curveFrames + 2
    var curveVector = [Float](repeating: 0.0, count: count)
    for index in 0..<count {
        let pos = Float(index) / Float(curveFrames)
        curveVector[index] = pos < 1.0 ? handler(pos) : handler(1.0)
    }
    return curveVector
}

private func convert(position: Float, curve: [Float]) -> Float {
    let frame = position * Float(curveFrames)
    let currentIndex = Int(frame)
    let currentValue = curve[currentIndex]
    let nextValue = curve[currentIndex + 1]
    let fraction = frame - Float(currentIndex)
    return currentValue + (nextValue - currentValue) * fraction
}

private let easeInSineCurve = makeCurve { sinf(($0 - 1.0) * .pi2) + 1.0 }
private let easeOutSineCurve = makeCurve { sinf($0 * .pi2) }
private let easeInOutSineCurve = makeCurve { (sinf(($0 * 2.0 - 1.0) * .pi2) + 1.0) * 0.5 }
private let easeInQuadCurve = makeCurve { $0 * $0 }
private let easeOutQuadCurve = makeCurve { -1.0 * $0 * ($0 - 2.0) }
private let easeInOutQuadCurve = makeCurve {
    let val = 2.0 * $0
    if val < 1.0 {
        return 0.5 * val * val
    } else if val < 1.0 {
        return 0.5 * val * val
    } else {
        let val = val - 1.0
        return -0.5 * (val * (val - 2.0) - 1.0)
    }
}
private let easeInCubicCurve = makeCurve { $0 * $0 * $0 }
private let easeOutCubicCurve = makeCurve {
    let val = $0 - 1.0
    return val * val * val + 1.0
}
private let easeInOutCubicCurve = makeCurve {
    let val = 2.0 * $0
    if val < 1.0 {
        return 0.5 * val * val * val
    } else {
        let val = val - 2.0
        return 0.5 * (val * val * val + 2.0)
    }
}
private let easeInQuartCurve = makeCurve { $0 * $0 * $0 * $0 }
private let easeOutQuartCurve = makeCurve {
    let val = $0 - 1.0
    return -1.0 * (val * val * val * val - 1.0)
}
private let easeInOutQuartCurve = makeCurve {
    let val = 2.0 * $0
    if val < 1.0 {
        return 0.5 * val * val * val * val
    } else {
        let val = val - 2.0
        return -0.5 * (val * val * val * val - 2.0)
    }
}
private let easeInQuintCurve = makeCurve { $0 * $0 * $0 * $0 * $0 }
private let easeOutQuintCurve = makeCurve {
    let val = $0 - 1.0
    return val * val * val * val * val + 1.0
}
private let easeInOutQuintCurve = makeCurve {
    let val = 2.0 * $0
    if val < 1.0 {
        return 0.5 * val * val * val * val * val
    } else {
        let val = val - 2.0
        return 0.5 * (val * val * val * val * val + 2.0)
    }
}
private let easeInExpoValueHandler: Transformer.Handler = {
    pow(2.0, 10.0 * ($0 - 1.0))
}
private let easeInExpoZero = easeInExpoValueHandler(0.0)
private let easeInExpoDiff = easeInExpoValueHandler(1.0) - easeInExpoZero
private let easeInExpoCurve = makeCurve {
    (easeInExpoValueHandler($0) - easeInExpoZero) / easeInExpoDiff
}
private let easeOutExpoValueHandler: Transformer.Handler = {
    1.0 - pow(2.0, -10.0 * $0)
}
private let easeOutExpoOne = easeOutExpoValueHandler(1.0)
private let easeOutExpoCurve = makeCurve {
    easeOutExpoValueHandler($0) / easeOutExpoOne
}
private let easeInOutExpoCurve = makeCurve {
    let val = $0 * 2.0
    if val < 1.0 {
        return 0.5 * Transformer.easeInExpo.transform(val)
    } else {
        return 0.5 * Transformer.easeOutExpo.transform(val - 1.0) + 0.5
    }
}
private let easeInCircCurve = makeCurve { 1.0 - sqrt(1.0 - $0 * $0) }
private let easeOutCircCurve = makeCurve {
    let val = $0 - 1.0
    return sqrt(1.0 - val * val)
}
private let easeInOutCircCurve = makeCurve {
    let val = 2.0 * $0
    if val < 1.0 {
        return -0.5 * (sqrt(1.0 - val * val) - 1.0)
    } else {
        let val = val - 2.0
        return 0.5 * (sqrt(1.0 - val * val) + 1.0)
    }
}
private let pingPongCurve = makeCurve {
    let val = $0 * 2.0
    if val > 1.0 {
        return 2.0 - val
    } else {
        return val
    }
}
private let reverseCurve = makeCurve { 1.0 - $0 }

public struct Transformer: Sendable {
    public typealias Handler = @Sendable (Float) -> Float

    private let transform: @Sendable (Float) -> Float

    public init(_ transform: @escaping @Sendable (Float) -> Float) {
        self.transform = transform
    }

    public func transform(_ value: Float) -> Float {
        transform(value)
    }

    public static let easeInSine = Transformer { position in
        convert(position: position, curve: easeInSineCurve)
    }

    public static let easeOutSine = Transformer { position in
        convert(position: position, curve: easeOutSineCurve)
    }

    public static let easeInOutSine = Transformer { position in
        convert(position: position, curve: easeInOutSineCurve)
    }

    public static let easeInQuad = Transformer { position in
        convert(position: position, curve: easeInQuadCurve)
    }

    public static let easeOutQuad = Transformer { position in
        convert(position: position, curve: easeOutQuadCurve)
    }

    public static let easeInOutQuad = Transformer { position in
        convert(position: position, curve: easeInOutQuadCurve)
    }

    public static let easeInCubic = Transformer { position in
        convert(position: position, curve: easeInCubicCurve)
    }

    public static let easeOutCubic = Transformer { position in
        convert(position: position, curve: easeOutCubicCurve)
    }

    public static let easeInOutCubic = Transformer { position in
        convert(position: position, curve: easeInOutCubicCurve)
    }

    public static let easeInQuart = Transformer { position in
        convert(position: position, curve: easeInQuartCurve)
    }

    public static let easeOutQuart = Transformer { position in
        convert(position: position, curve: easeOutQuartCurve)
    }

    public static let easeInOutQuart = Transformer { position in
        convert(position: position, curve: easeInOutQuartCurve)
    }

    public static let easeInQuint = Transformer { position in
        convert(position: position, curve: easeInQuintCurve)
    }

    public static let easeOutQuint = Transformer { position in
        convert(position: position, curve: easeOutQuintCurve)
    }

    public static let easeInOutQuint = Transformer { position in
        convert(position: position, curve: easeInOutQuintCurve)
    }

    public static let easeInExpo = Transformer { position in
        convert(position: position, curve: easeInExpoCurve)
    }

    public static let easeOutExpo = Transformer { position in
        convert(position: position, curve: easeOutExpoCurve)
    }

    public static let easeInOutExpo = Transformer { position in
        convert(position: position, curve: easeInOutExpoCurve)
    }

    public static let easeInCirc = Transformer { position in
        convert(position: position, curve: easeInCircCurve)
    }

    public static let easeOutCirc = Transformer { position in
        convert(position: position, curve: easeOutCircCurve)
    }

    public static let easeInOutCirc = Transformer { position in
        convert(position: position, curve: easeInOutCircCurve)
    }

    public static let pingPong = Transformer { position in
        convert(position: position, curve: pingPongCurve)
    }

    public static let reverse = Transformer { position in
        convert(position: position, curve: reverseCurve)
    }

    public static let linear = Transformer { position in
        position
    }

    public func connect(_ other: Transformer) -> Transformer {
        Transformer { value in
            other.transform(self.transform(value))
        }
    }
}

extension Array where Element == Transformer {
    public var connected: Transformer {
        reduce(Transformer { $0 }) { result, transformer in
            result.connect(transformer)
        }
    }
}
