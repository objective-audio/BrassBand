import Testing

@testable import BrassBand

struct JustifyTests {
    @Test func withRatiosArray() {
        let jusitified = justify(begin: 1.0, end: 7.0, ratios: [1.0, 2.0])

        #expect(jusitified == [1.0, 3.0, 7.0])
    }

    @Test func withEmptyRatios() {
        let jusitified = justify(begin: 1.0, end: 7.0, ratios: [])

        #expect(jusitified == [4.0], "1.0 + (7.0 - 1.0) * 0.5")
    }
}
