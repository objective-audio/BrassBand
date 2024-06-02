import Testing

@testable import BrassBand

struct TimeIntervalTests {
    @Test func initWithDuration() async throws {
        #expect(TimeInterval(1.0) == TimeInterval(Duration.seconds(1)))
        #expect(TimeInterval(0.5) == TimeInterval(Duration.seconds(0.5)))
        #expect(TimeInterval(1.5) == TimeInterval(Duration.seconds(1.5)))
    }
}
