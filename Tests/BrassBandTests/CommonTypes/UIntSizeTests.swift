import BrassBand
import Testing

struct UIntSizeTests {
    @Test func isEqual() {
        let size1_2a = UIntSize(width: 1, height: 2)
        let size1_2b = UIntSize(width: 1, height: 2)
        let size1_3 = UIntSize(width: 1, height: 3)
        let size2_2 = UIntSize(width: 2, height: 2)

        #expect(size1_2a == size1_2a)
        #expect(size1_2a == size1_2b)
        #expect(size1_2a != size1_3)
        #expect(size1_2a != size2_2)
    }

    @Test func zero() {
        #expect(UIntSize.zero.width == 0)
        #expect(UIntSize.zero.height == 0)
    }
}
