import BrassBand
import Testing

struct ColorTests {
    @Test func initWithSingleValue() {
        let color = Color(repeating: 1.0)

        #expect(color.red == 1.0)
        #expect(color.green == 1.0)
        #expect(color.blue == 1.0)
        #expect(color.alpha.value == 1.0)

        #expect(color.rgb.red == 1.0)
        #expect(color.rgb.green == 1.0)
        #expect(color.rgb.blue == 1.0)
    }

    @Test func initWithValues() {
        let color = Color(red: 1.0, green: 2.0, blue: 3.0, alpha: 4.0)

        #expect(color.red == 1.0)
        #expect(color.green == 2.0)
        #expect(color.blue == 3.0)
        #expect(color.alpha.value == 4.0)

        #expect(color.rgb.red == 1.0)
        #expect(color.rgb.green == 2.0)
        #expect(color.rgb.blue == 3.0)
    }

    @Test func initWithRGB() {
        let rgb = RgbColor(red: 1.1, green: 2.2, blue: 3.3)
        let color = Color(rgb: rgb)

        #expect(color.red == 1.1)
        #expect(color.green == 2.2)
        #expect(color.blue == 3.3)
        #expect(color.alpha.value == 1.0)
    }

    @Test func initWithRGBAndAlpha() {
        let rgb = RgbColor(red: 1.0, green: 2.0, blue: 3.0)
        let alpha = Alpha(value: 4.0)
        let color = Color(rgb: rgb, alpha: alpha)

        #expect(color.red == 1.0)
        #expect(color.green == 2.0)
        #expect(color.blue == 3.0)
        #expect(color.alpha.value == 4.0)
    }

    @Test func simd4() {
        let color = Color(red: 1.0, green: 2.0, blue: 3.0, alpha: 4.0)

        #expect(color.simd4[0] == 1.0)
        #expect(color.simd4[1] == 2.0)
        #expect(color.simd4[2] == 3.0)
        #expect(color.simd4[3] == 4.0)
    }

    @Test func isEqual() {
        let color1 = Color(red: 1.0, green: 2.0, blue: 3.0, alpha: 4.0)
        let color2 = Color(red: 1.0, green: 2.0, blue: 3.0, alpha: 4.0)
        let color3 = Color(red: 1.1, green: 2.0, blue: 3.0, alpha: 4.0)
        let color4 = Color(red: 1.0, green: 2.1, blue: 3.0, alpha: 4.0)
        let color5 = Color(red: 1.0, green: 2.0, blue: 3.1, alpha: 4.0)
        let color6 = Color(red: 1.0, green: 2.0, blue: 3.0, alpha: 4.1)

        let color7 = Color(red: 1.1, green: 2.1, blue: 3.1, alpha: 4.1)

        let colorZero1 = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let colorZero2 = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

        #expect(color1 == color2)
        #expect(color1 != color3)
        #expect(color1 != color4)
        #expect(color1 != color5)
        #expect(color1 != color6)
        #expect(color1 != color7)
        #expect(colorZero1 == colorZero2)
    }

    @Test func setByProperties() {
        var color = Color()

        #expect(color == .init(rgb: .black, alpha: .init(value: 0.0)))

        color.alpha = .init(value: 1.0)

        #expect(color == .init(rgb: .black, alpha: .init(value: 1.0)))

        color.red = 1.0

        #expect(color == .init(rgb: .red, alpha: .init(value: 1.0)))

        color.red = 0.0
        color.green = 1.0

        #expect(color == .init(rgb: .green, alpha: .init(value: 1.0)))

        color.green = 0.0
        color.blue = 1.0

        #expect(color == .init(rgb: .blue, alpha: .init(value: 1.0)))

        color.rgb = .yellow

        #expect(color == .init(rgb: .yellow, alpha: .init(value: 1.0)))
    }
}
