import Foundation

extension CursorTracker {
    @MainActor
    public protocol Detector: AnyObject {
        func detect(location: Point, collider: Collider) -> Bool
    }

    @MainActor
    public protocol EventInput: AnyObject {
        var cursorPublisher: AnyPublisher<CursorEvent, Never> { get }
    }

    @MainActor
    public protocol Renderer: AnyObject {
        var willRender: AnyPublisher<Void, Never> { get }
    }
}

extension Detector: CursorTracker.Detector {}
extension EventInput: CursorTracker.EventInput {}
extension Renderer: CursorTracker.Renderer {}
