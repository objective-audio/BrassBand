import Foundation
import simd

extension Vertex2dRect: @retroactive Equatable {}

extension Vertex2dRect {
    public mutating func setPositions(_ positions: RegionPositions) {
        vertices.0.position = positions[0]
        vertices.1.position = positions[1]
        vertices.2.position = positions[2]
        vertices.3.position = positions[3]
    }

    public mutating func applyMatrixToPositions(_ matrix: simd_float4x4) {
        vertices.0.position.apply(matrix: matrix)
        vertices.1.position.apply(matrix: matrix)
        vertices.2.position.apply(matrix: matrix)
        vertices.3.position.apply(matrix: matrix)
    }

    public func appliedToPositions(matrix: simd_float4x4) -> Vertex2dRect {
        var rect = self
        rect.applyMatrixToPositions(matrix)
        return rect
    }

    public mutating func setTexCoords(_ positions: RegionPositions) {
        vertices.0.texCoord = positions[0]
        vertices.1.texCoord = positions[1]
        vertices.2.texCoord = positions[2]
        vertices.3.texCoord = positions[3]
    }

    public mutating func setColors(_ color: SIMD4<Float>) {
        vertices.0.color = color
        vertices.1.color = color
        vertices.2.color = color
        vertices.3.color = color
    }

    public mutating func setColors(_ color: Color) {
        setColors(color.simd4)
    }
}

extension Vertex2dRect {
    public static var empty: Vertex2dRect {
        var rect = Vertex2dRect()
        rect.vertices.0 = .init(position: .zero, texCoord: .zero, color: .zero)
        rect.vertices.1 = .init(position: .zero, texCoord: .zero, color: .zero)
        rect.vertices.2 = .init(position: .zero, texCoord: .zero, color: .zero)
        rect.vertices.3 = .init(position: .zero, texCoord: .zero, color: .zero)
        return rect
    }
}
