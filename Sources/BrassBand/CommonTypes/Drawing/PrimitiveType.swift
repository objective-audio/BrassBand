import Foundation

public enum PrimitiveType: Sendable {
    case point, line, lineStrip, triangle, triangleStrip
}

extension PrimitiveType {
    var mtl: MTLPrimitiveType {
        switch self {
        case .point: return .point
        case .line: return .line
        case .lineStrip: return .lineStrip
        case .triangle: return .triangle
        case .triangleStrip: return .triangleStrip
        }
    }
}
