import Foundation

public protocol Shape {
    var kind: Collider.Kind { get }
    func hitTest(_ point: Point) -> Bool
    func hitTest(_ region: Region) -> Bool
}
