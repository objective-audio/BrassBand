import Foundation

extension TouchTracker {
    @MainActor
    public protocol Detector: AnyObject {
        func detect(location: Point, collider: Collider) -> Bool
    }

    @MainActor
    public protocol EventInput: AnyObject {
        var touchPublisher: AnyPublisher<TouchEvent, Never> { get }
    }

    @MainActor
    public protocol Renderer: AnyObject {
        var willRender: AnyPublisher<Void, Never> { get }
    }

    @MainActor
    public protocol Node: AnyObject {
        var isEnabledPublisher: AnyPublisher<Bool, Never> { get }
        var colliders: [Collider] { get }
        var collidersPublisher: AnyPublisher<[Collider], Never> { get }
    }
}

extension Detector: TouchTracker.Detector {}
extension EventInput: TouchTracker.EventInput {}
extension Renderer: TouchTracker.Renderer {}
extension Node: TouchTracker.Node {}
