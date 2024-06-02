import Foundation

extension TimeInterval {
    init(_ duration: Duration) {
        let (seconds, attoSeconds) = duration.components
        let timeInterval = Double(seconds) + Double(attoSeconds) * 1.0e-18
        self.init(timeInterval)
    }
}
