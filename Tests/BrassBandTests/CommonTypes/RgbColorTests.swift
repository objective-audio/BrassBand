import BrassBand
import Testing

struct RgbColorTests {
    @Test func initWithSingleValue() {
        let color = RgbColor(repeating: 1.0)

        #expect(color.red == 1.0)
        #expect(color.green == 1.0)
        #expect(color.blue == 1.0)
    }

    @Test func initWithValues() {
        let color = RgbColor(red: 1.0, green: 2.0, blue: 3.0)

        #expect(color.red == 1.0)
        #expect(color.green == 2.0)
        #expect(color.blue == 3.0)
    }

    @Test func isEqual() {
        let color1 = RgbColor(red: 1.0, green: 2.0, blue: 3.0)
        let color2 = RgbColor(red: 1.0, green: 2.0, blue: 3.0)
        let color3 = RgbColor(red: 1.1, green: 2.0, blue: 3.0)
        let color4 = RgbColor(red: 1.0, green: 2.1, blue: 3.0)
        let color5 = RgbColor(red: 1.0, green: 2.0, blue: 3.1)
        let color6 = RgbColor(red: 1.1, green: 2.1, blue: 3.0)
        let colorZero1 = RgbColor(repeating: 0.0)
        let colorZero2 = RgbColor(repeating: 0.0)

        #expect(color1 == color2)
        #expect(color1 != color3)
        #expect(color1 != color4)
        #expect(color1 != color5)
        #expect(color1 != color6)
        #expect(colorZero1 == colorZero2)
    }

    @Test func multiply() {
        let color1 = RgbColor(red: 0.1, green: 0.5, blue: 1.0)
        let color2 = RgbColor(red: 0.5, green: 0.5, blue: 0.5)

        #expect(color1 * color2 == RgbColor(red: 0.05, green: 0.25, blue: 0.5))
        #expect(color1 * 0.5 == RgbColor(red: 0.05, green: 0.25, blue: 0.5))
    }

    @Test func staticColors() {
        #expect(RgbColor.white.red == 1.0)
        #expect(RgbColor.white.green == 1.0)
        #expect(RgbColor.white.blue == 1.0)

        #expect(RgbColor.black.red == 0.0)
        #expect(RgbColor.black.green == 0.0)
        #expect(RgbColor.black.blue == 0.0)

        #expect(RgbColor.gray.red == 0.5)
        #expect(RgbColor.gray.green == 0.5)
        #expect(RgbColor.gray.blue == 0.5)

        #expect(RgbColor.darkGray.red == 0.333)
        #expect(RgbColor.darkGray.green == 0.333)
        #expect(RgbColor.darkGray.blue == 0.333)

        #expect(RgbColor.lightGray.red == 0.667)
        #expect(RgbColor.lightGray.green == 0.667)
        #expect(RgbColor.lightGray.blue == 0.667)

        #expect(RgbColor.red.red == 1.0)
        #expect(RgbColor.red.green == 0.0)
        #expect(RgbColor.red.blue == 0.0)

        #expect(RgbColor.green.red == 0.0)
        #expect(RgbColor.green.green == 1.0)
        #expect(RgbColor.green.blue == 0.0)

        #expect(RgbColor.blue.red == 0.0)
        #expect(RgbColor.blue.green == 0.0)
        #expect(RgbColor.blue.blue == 1.0)

        #expect(RgbColor.cyan.red == 0.0)
        #expect(RgbColor.cyan.green == 1.0)
        #expect(RgbColor.cyan.blue == 1.0)

        #expect(RgbColor.yellow.red == 1.0)
        #expect(RgbColor.yellow.green == 1.0)
        #expect(RgbColor.yellow.blue == 0.0)

        #expect(RgbColor.magenta.red == 1.0)
        #expect(RgbColor.magenta.green == 0.0)
        #expect(RgbColor.magenta.blue == 1.0)

        #expect(RgbColor.orange.red == 1.0)
        #expect(RgbColor.orange.green == 0.5)
        #expect(RgbColor.orange.blue == 0.0)

        #expect(RgbColor.purple.red == 0.5)
        #expect(RgbColor.purple.green == 0.0)
        #expect(RgbColor.purple.blue == 0.5)

        #expect(RgbColor.brown.red == 0.6)
        #expect(RgbColor.brown.green == 0.4)
        #expect(RgbColor.brown.blue == 0.2)
    }

    @Test func setByProperties() {
        var color = RgbColor()

        #expect(color == .black)

        color.red = 1.0

        #expect(color == .red)

        color.red = 0.0
        color.green = 1.0

        #expect(color == .green)

        color.green = 0.0
        color.blue = 1.0

        #expect(color == .blue)
    }

    @Test func hsb() {
        #expect(RgbColor.hsb(hue: 0.0, saturation: 0.0, brightness: 1.0) == .white)
        #expect(RgbColor.hsb(hue: 0.0, saturation: 0.0, brightness: 0.5) == .gray)
        #expect(RgbColor.hsb(hue: 0.0, saturation: 0.0, brightness: 0.0) == .black)
        #expect(RgbColor.hsb(hue: 0.0, saturation: 1.0, brightness: 1.0) == .red)
        #expect(RgbColor.hsb(hue: 1.0 / 3.0, saturation: 1.0, brightness: 1.0) == .green)
        #expect(RgbColor.hsb(hue: 2.0 / 3.0, saturation: 1.0, brightness: 1.0) == .blue)
    }

    @Test func hsl() {
        #expect(RgbColor.hsl(hue: 0.0, saturation: 0.0, lightness: 1.0) == .white)
        #expect(RgbColor.hsl(hue: 0.0, saturation: 0.0, lightness: 0.5) == .gray)
        #expect(RgbColor.hsl(hue: 0.0, saturation: 0.0, lightness: 0.0) == .black)
        #expect(RgbColor.hsl(hue: 0.0, saturation: 1.0, lightness: 0.5) == .red)
        #expect(RgbColor.hsl(hue: 1.0 / 3.0, saturation: 1.0, lightness: 0.5) == .green)
        #expect(RgbColor.hsl(hue: 2.0 / 3.0, saturation: 1.0, lightness: 0.5) == .blue)
    }
}
