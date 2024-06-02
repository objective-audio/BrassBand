import Testing

@testable import BrassBand

@MainActor
struct DetectorTest {
    @Test func detectWithLocationOnly() {
        let detector = Detector()

        let collider1a = makeRectCollider(rect: .init(center: .zero, size: .one))
        let collider1b = makeRectCollider(rect: .init(center: .zero, size: .one))
        let collider2 = makeRectCollider(rect: .init(center: .init(x: 0.5, y: 0.0), size: .one))

        detector.beginUpdate()

        detector.add(collider: collider1a)
        detector.add(collider: collider1b)
        detector.add(collider: collider2)

        detector.endUpdate()

        // 1a、1bのみの場所。あとから追加した1bがヒットする
        #expect(detector.detect(location: .init(x: -0.25, y: 0.0)) === collider1b)
        // 全部ある場所。最後に追加した2がヒットする
        #expect(detector.detect(location: .init(x: 0.25, y: 0.0)) === collider2)
    }

    @Test func detectWithLocationAndCollider() {
        let detector = Detector()

        let collider1a = makeRectCollider(rect: .init(center: .zero, size: .one))
        let collider1b = makeRectCollider(rect: .init(center: .zero, size: .one))
        let collider2 = makeRectCollider(rect: .init(center: .init(x: 0.5, y: 0.0), size: .one))

        detector.beginUpdate()

        detector.add(collider: collider1a)
        detector.add(collider: collider1b)
        detector.add(collider: collider2)

        detector.endUpdate()

        #expect(detector.detect(location: .init(x: -0.25, y: 0.0), collider: collider1b))
        #expect(detector.detect(location: .init(x: 0.25, y: 0.0), collider: collider2))

        #expect(!detector.detect(location: .init(x: -0.25, y: 0.0), collider: collider1a))
        #expect(!detector.detect(location: .init(x: -0.25, y: 0.0), collider: collider2))
        #expect(!detector.detect(location: .init(x: 0.25, y: 0.0), collider: collider1a))
        #expect(!detector.detect(location: .init(x: 0.25, y: 0.0), collider: collider1b))
    }

    @Test func cannotAddColliderWithoutUpdate() {
        let detector = Detector()

        let collider = makeRectCollider(rect: .init(center: .zero, size: .one))

        // colliderを追加するにはbeginUpdateの呼び出しが必要
        // detector.beginUpdate()

        detector.add(collider: collider)

        #expect(detector.detect(location: .zero) == nil)
    }

    @Test func clearCollidersAtBeginUpdate() {
        let detector = Detector()

        let collider = makeRectCollider(rect: .init(center: .zero, size: .one))

        detector.beginUpdate()
        detector.add(collider: collider)
        detector.endUpdate()

        #expect(detector.detect(location: .zero) === collider)

        detector.beginUpdate()

        #expect(detector.detect(location: .zero) == nil)
    }

    @Test func isUpdating() {
        let detector = Detector()

        #expect(!detector.isUpdating)

        detector.beginUpdate()

        #expect(detector.isUpdating)

        detector.endUpdate()

        #expect(!detector.isUpdating)
    }
}

extension DetectorTest {
    private func makeRectCollider(rect: Region) -> Collider {
        let collider = Collider(shape: RectShape(rect: rect))
        collider.matrix = matrix_identity_float4x4
        return collider
    }
}
