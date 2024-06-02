import Testing

@testable import BrassBand

struct ImageDataTests {
    @Test func draw() throws {
        let imageSize = try #require(ImageSize(pointSize: .init(width: 2, height: 2)))

        let imageData = try #require(
            ImageData.make(size: imageSize) { context in
                context.setFillColor(Color(repeating: 1.0).cgColor)
                context.fill(.init(x: 0, y: 0, width: 2, height: 2))
            })

        let dataSize = 2 * 2 * 4
        let data = imageData.data.bindMemory(to: UInt8.self, capacity: dataSize)

        for index in 0..<dataSize {
            #expect(data[index] == 0xFF)
        }
    }
}
