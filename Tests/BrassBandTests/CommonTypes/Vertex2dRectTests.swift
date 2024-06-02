import BrassBand
import Testing

struct Vertex2dRectTests {
    @Test func setPositions() {
        var rect = Vertex2dRect()

        rect.setPositions(
            .init(.init(origin: .init(x: 0.0, y: 1.0), size: .init(width: 2.0, height: 4.0))))

        #expect(rect.vertices.0.position == .init(0.0, 1.0))
        #expect(rect.vertices.1.position == .init(2.0, 1.0))
        #expect(rect.vertices.2.position == .init(0.0, 5.0))
        #expect(rect.vertices.3.position == .init(2.0, 5.0))
    }

    @Test func setTexCoords() {
        var rect = Vertex2dRect()

        rect.setTexCoords(
            .init(.init(origin: .init(x: 0.0, y: 1.0), size: .init(width: 2.0, height: 4.0))))

        #expect(rect.vertices.0.texCoord == .init(0.0, 1.0))
        #expect(rect.vertices.1.texCoord == .init(2.0, 1.0))
        #expect(rect.vertices.2.texCoord == .init(0.0, 5.0))
        #expect(rect.vertices.3.texCoord == .init(2.0, 5.0))
    }

    @Test func setColors() {
        var rect = Vertex2dRect()

        rect.setColors(.init(0.25, 0.5, 0.75, 1.0))

        #expect(rect.vertices.0.color == .init(0.25, 0.5, 0.75, 1.0))
        #expect(rect.vertices.1.color == .init(0.25, 0.5, 0.75, 1.0))
        #expect(rect.vertices.2.color == .init(0.25, 0.5, 0.75, 1.0))
        #expect(rect.vertices.3.color == .init(0.25, 0.5, 0.75, 1.0))
    }

    @Test func isEqual() {
        var rect1 = Vertex2dRect()
        rect1.setPositions(.zero)
        rect1.setTexCoords(.zero)
        rect1.setColors(.init(rgb: .white, alpha: .one))

        var rect1b = Vertex2dRect()
        rect1b.setPositions(.zero)
        rect1b.setTexCoords(.zero)
        rect1b.setColors(.init(rgb: .white, alpha: .one))

        var rect2 = Vertex2dRect()
        rect2.setPositions(.zero)
        rect2.setTexCoords(.zero)
        rect2.setColors(.init(rgb: .red, alpha: .one))

        #expect(rect1 == rect1b)
        #expect(rect1 != rect2)
    }

    @Test func applyMatrixToPositions() {
        var rect = Vertex2dRect()
        rect.setPositions(
            .init(.init(origin: .init(x: 0.0, y: 1.0), size: .init(width: 2.0, height: 4.0))))

        rect.applyMatrixToPositions(.translation(x: 1.0, y: 2.0))

        #expect(rect.vertices.0.position == .init(1.0, 3.0))
        #expect(rect.vertices.1.position == .init(3.0, 3.0))
        #expect(rect.vertices.2.position == .init(1.0, 7.0))
        #expect(rect.vertices.3.position == .init(3.0, 7.0))
    }

    @Test func appliedToPositionsWithMatrix() {
        var rect = Vertex2dRect()
        rect.setPositions(
            .init(.init(origin: .init(x: 0.0, y: 1.0), size: .init(width: 2.0, height: 4.0))))

        let appliedRect = rect.appliedToPositions(matrix: .translation(x: 1.0, y: 2.0))

        #expect(appliedRect.vertices.0.position == .init(1.0, 3.0))
        #expect(appliedRect.vertices.1.position == .init(3.0, 3.0))
        #expect(appliedRect.vertices.2.position == .init(1.0, 7.0))
        #expect(appliedRect.vertices.3.position == .init(3.0, 7.0))
    }
}
