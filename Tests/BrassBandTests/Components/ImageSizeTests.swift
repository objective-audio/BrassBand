import Testing

@testable import BrassBand

@MainActor
struct ImageSizeTests {
    @Test func initWithoutScaleFactor() throws {
        let imageSize = try #require(ImageSize(pointSize: .init(width: 4, height: 2)))

        #expect(imageSize.point == .init(width: 4, height: 2))
        #expect(imageSize.actual == .init(width: 4, height: 2))
        #expect(imageSize.scaleFactor == 1.0)
    }

    @Test func initWithScaleFactor() throws {
        let imageSize = try #require(
            ImageSize(pointSize: .init(width: 6, height: 3), scaleFactor: 2.0))

        #expect(imageSize.point == .init(width: 6, height: 3))
        #expect(imageSize.actual == .init(width: 12, height: 6))
        #expect(imageSize.scaleFactor == 2.0)
    }
}
