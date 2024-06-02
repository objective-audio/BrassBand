import BrassBand
import Testing

struct Vertex2dTests {
    @Test func equal() {
        #expect(
            Vertex2d(
                position: .init(repeating: 1.0), texCoord: .init(repeating: 2.0),
                color: .init(repeating: 4.0))
                == Vertex2d(
                    position: .init(repeating: 1.0), texCoord: .init(repeating: 2.0),
                    color: .init(repeating: 4.0)))
        #expect(
            Vertex2d(
                position: .init(repeating: 1.0), texCoord: .init(repeating: 2.0),
                color: .init(repeating: 4.0))
                != Vertex2d(
                    position: .init(repeating: 8.0), texCoord: .init(repeating: 2.0),
                    color: .init(repeating: 4.0)))
        #expect(
            Vertex2d(
                position: .init(repeating: 1.0), texCoord: .init(repeating: 2.0),
                color: .init(repeating: 4.0))
                != Vertex2d(
                    position: .init(repeating: 1.0), texCoord: .init(repeating: 8.0),
                    color: .init(repeating: 4.0)))
        #expect(
            Vertex2d(
                position: .init(repeating: 1.0), texCoord: .init(repeating: 2.0),
                color: .init(repeating: 4.0))
                != Vertex2d(
                    position: .init(repeating: 1.0), texCoord: .init(repeating: 2.0),
                    color: .init(repeating: 8.0)))
    }
}
