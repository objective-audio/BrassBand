import Foundation

public protocol ActionProvidable: Sendable {
    var action: Action { get }
}
