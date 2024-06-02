import BrassBandCpp
import Metal
import Testing

struct ShaderBundleTests {
    @Test func bundle() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        #expect(ShaderBundle.defaultMetalLibrary(device: device) != nil)
    }
}
