import Foundation

extension Color {
    public var cgColor: CGColor {
        .init(
            red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue),
            alpha: CGFloat(alpha.value))
    }
}
