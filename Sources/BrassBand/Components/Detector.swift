import Foundation

@MainActor
public final class Detector {
    public private(set) var isUpdating: Bool = false

    private var colliders: [Collider] = []

    public init() {}

    public func detect(location: Point) -> Collider? {
        for collider in colliders.reversed() {
            if collider.hitTest(location) {
                return collider
            }
        }
        return nil
    }

    public func detect(location: Point, collider: Collider) -> Bool {
        guard let detected = detect(location: location), detected === collider else {
            return false
        }
        return true
    }
}

extension Detector: Renderer.Detector {
    public func beginUpdate() {
        isUpdating = true
        colliders.removeAll()
    }

    public func endUpdate() {
        isUpdating = false
    }
}

extension Detector: DetectorForRenderInfo {
    public func add(collider: Collider) {
        guard isUpdating else { return }
        colliders.append(collider)
    }
}
