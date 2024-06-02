import Testing

@testable import BrassBand

@MainActor
struct MeshBufferTests {
    @Test func writeAndRead() {
        let buffer = MeshBuffer<Vertex2d>(capacity: 2)

        buffer.write {
            $0[0].color = Color(rgb: .red, alpha: .one).simd4
            $0[0].position = .init(x: 1.0, y: -1.0)
            $0[0].texCoord = .init(x: 0.5, y: 0.25)

            $0[1].color = Color(rgb: .blue, alpha: .init(value: 0.5)).simd4
            $0[1].position = .init(x: -1.0, y: 1.0)
            $0[1].texCoord = .init(x: 0.25, y: 0.5)
        }

        buffer.read {
            #expect($0[0].color == Color(rgb: .red, alpha: .one).simd4)
            #expect($0[0].position == .init(x: 1.0, y: -1.0))
            #expect($0[0].texCoord == .init(x: 0.5, y: 0.25))

            #expect($0[1].color == Color(rgb: .blue, alpha: .init(value: 0.5)).simd4)
            #expect($0[1].position == .init(x: -1.0, y: 1.0))
            #expect($0[1].texCoord == .init(x: 0.25, y: 0.5))
        }
    }
}
