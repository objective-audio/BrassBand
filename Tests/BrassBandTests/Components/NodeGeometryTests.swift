import Testing

@testable import BrassBand

@MainActor
struct NodeGeometryTests {
    @Test func position() {
        var geometry = Node.Geometry()

        #expect(geometry.position == .zero)
        #expect(geometry.x == 0.0)
        #expect(geometry.y == 0.0)

        geometry.position = .init(x: 1.0, y: 2.0)

        #expect(geometry.position == .init(x: 1.0, y: 2.0))
        #expect(geometry.x == 1.0)
        #expect(geometry.y == 2.0)

        geometry.x = 4.0

        #expect(geometry.position == .init(x: 4.0, y: 2.0))
        #expect(geometry.x == 4.0)
        #expect(geometry.y == 2.0)

        geometry.y = 8.0

        #expect(geometry.position == .init(x: 4.0, y: 8.0))
        #expect(geometry.x == 4.0)
        #expect(geometry.y == 8.0)
    }

    @Test func angle() {
        var geometry = Node.Geometry()

        #expect(geometry.angle == .init(degrees: 0.0))

        geometry.angle = .init(degrees: 180.0)

        #expect(geometry.angle == .init(degrees: 180.0))
    }

    @Test func scale() {
        var geometry = Node.Geometry()

        #expect(geometry.scale == .one)
        #expect(geometry.width == 1.0)
        #expect(geometry.height == 1.0)

        geometry.scale = .init(width: 2.0, height: 4.0)

        #expect(geometry.scale == .init(width: 2.0, height: 4.0))
        #expect(geometry.width == 2.0)
        #expect(geometry.height == 4.0)

        geometry.width = 8.0

        #expect(geometry.scale == .init(width: 8.0, height: 4.0))
        #expect(geometry.width == 8.0)
        #expect(geometry.height == 4.0)

        geometry.height = 16.0

        #expect(geometry.scale == .init(width: 8.0, height: 16.0))
        #expect(geometry.width == 8.0)
        #expect(geometry.height == 16.0)
    }

    @Test func matrix() {
        var geometry = Node.Geometry()
        geometry.position = .init(x: 10.0, y: -20.0)
        geometry.scale = .init(width: 2.0, height: 0.5)
        geometry.angle = .init(degrees: 90.0)

        let expectedMatrix =
            simd_float4x4.translation(position: geometry.position)
            * simd_float4x4.rotation(angle: geometry.angle)
            * simd_float4x4.scaling(scale: geometry.scale)

        #expect(geometry.matrix == expectedMatrix)
    }

    @Test func convertPosition() {
        let node = Node()
        let subNode = Node()
        node.appendSubNode(subNode)
        node.geometry.position = .init(x: -1.0, y: -1.0)
        node.geometry.scale = .init(width: 1.0 / 200.0, height: 1.0 / 100.0)

        let convertedPosition = subNode.convertPosition(.init(x: 1.0, y: -0.5))
        #expect(convertedPosition.x.isApproximatelyEqual(to: 400.0, absoluteTolerance: 0.001))
        #expect(convertedPosition.y.isApproximatelyEqual(to: 50.0, absoluteTolerance: 0.001))
    }

    @Test func treeMatrix() {
        let rootNode = Node()
        rootNode.geometry.position = .init(x: 10.0, y: -10.0)
        rootNode.geometry.scale = .init(width: 2.0, height: 0.5)
        rootNode.geometry.angle = .init(degrees: 90.0)

        let subNode = Node()
        subNode.geometry.position = .init(x: -50.0, y: 10.0)
        subNode.geometry.scale = .init(width: 0.25, height: 3.0)
        subNode.geometry.angle = .init(degrees: -45.0)

        rootNode.appendSubNode(subNode)

        let rootLocalMatrix =
            simd_float4x4.translation(position: rootNode.geometry.position)
            * simd_float4x4.rotation(angle: rootNode.geometry.angle)
            * simd_float4x4.scaling(scale: rootNode.geometry.scale)
        let subLocalMatrix =
            simd_float4x4.translation(position: subNode.geometry.position)
            * simd_float4x4.rotation(angle: subNode.geometry.angle)
            * simd_float4x4.scaling(scale: subNode.geometry.scale)
        let expectedMatrix = rootLocalMatrix * subLocalMatrix

        #expect(subNode.treeMatrix == expectedMatrix)
    }
}
