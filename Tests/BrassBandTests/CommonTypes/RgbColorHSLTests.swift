import BrassBand
import Testing

struct RgbColorHSLTests {
    @Test func white() {
        do {
            let color = RgbColor.hsl(hue: 0.0, saturation: 0.0, lightness: 1.0)
            #expect(color.red == 1.0)
            #expect(color.green == 1.0)
            #expect(color.blue == 1.0)
        }

        do {
            let color = RgbColor.hsl(hue: 0.5, saturation: 0.0, lightness: 1.0)
            #expect(color.red == 1.0)
            #expect(color.green == 1.0)
            #expect(color.blue == 1.0)
        }

        do {
            let color = RgbColor.hsl(hue: 0.9, saturation: 0.0, lightness: 1.0)
            #expect(color.red == 1.0)
            #expect(color.green == 1.0)
            #expect(color.blue == 1.0)
        }
    }

    @Test func black() {
        do {
            let color = RgbColor.hsl(hue: 0.0, saturation: 0.0, lightness: 0.0)
            #expect(color.red == 0.0)
            #expect(color.green == 0.0)
            #expect(color.blue == 0.0)
        }

        do {
            let color = RgbColor.hsl(hue: 0.5, saturation: 0.0, lightness: 0.0)
            #expect(color.red == 0.0)
            #expect(color.green == 0.0)
            #expect(color.blue == 0.0)
        }

        do {
            let color = RgbColor.hsl(hue: 0.9, saturation: 0.0, lightness: 0.0)
            #expect(color.red == 0.0)
            #expect(color.green == 0.0)
            #expect(color.blue == 0.0)
        }
    }

    @Test func gray() {
        do {
            let color = RgbColor.hsl(hue: 0.0, saturation: 0.0, lightness: 0.5)
            #expect(color.red == 0.5)
            #expect(color.green == 0.5)
            #expect(color.blue == 0.5)
        }

        do {
            let color = RgbColor.hsl(hue: 0.5, saturation: 0.0, lightness: 0.5)
            #expect(color.red == 0.5)
            #expect(color.green == 0.5)
            #expect(color.blue == 0.5)
        }

        do {
            let color = RgbColor.hsl(hue: 0.9, saturation: 0.0, lightness: 0.5)
            #expect(color.red == 0.5)
            #expect(color.green == 0.5)
            #expect(color.blue == 0.5)
        }
    }

    @Test func red() {
        do {
            let color = RgbColor.hsl(hue: 0.0, saturation: 1.0, lightness: 0.5)
            #expect(color.red == 1.0)
            #expect(color.green == 0.0)
            #expect(color.blue == 0.0)
        }

        do {
            let color = RgbColor.hsl(hue: 1.0, saturation: 1.0, lightness: 0.5)
            #expect(color.red == 1.0)
            #expect(color.green == 0.0)
            #expect(color.blue == 0.0)
        }
    }

    @Test func redYellow() {
        let color = RgbColor.hsl(hue: 0.25 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 1.0)
        #expect(color.green == 0.25)
        #expect(color.blue == 0.0)
    }

    @Test func yellow() {
        let color = RgbColor.hsl(hue: 1.0 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 1.0)
        #expect(color.green == 1.0)
        #expect(color.blue == 0.0)
    }

    @Test func yellowGreen() {
        let color = RgbColor.hsl(hue: 1.25 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.75)
        #expect(color.green == 1.0)
        #expect(color.blue == 0.0)
    }

    @Test func green() {
        let color = RgbColor.hsl(hue: 2.0 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.0)
        #expect(color.green == 1.0)
        #expect(color.blue == 0.0)
    }

    @Test func greenCyan() {
        let color = RgbColor.hsl(hue: 2.25 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.0)
        #expect(color.green == 1.0)
        #expect(color.blue == 0.25)
    }

    @Test func cyan() {
        let color = RgbColor.hsl(hue: 3.0 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.0)
        #expect(color.green == 1.0)
        #expect(color.blue == 1.0)
    }

    @Test func cyanBlue() {
        let color = RgbColor.hsl(hue: 3.25 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.0)
        #expect(color.green == 0.75)
        #expect(color.blue == 1.0)
    }

    @Test func blue() {
        let color = RgbColor.hsl(hue: 4.0 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.0)
        #expect(color.green == 0.0)
        #expect(color.blue == 1.0)
    }

    @Test func blueMagenta() {
        let color = RgbColor.hsl(hue: 4.25 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 0.25)
        #expect(color.green == 0.0)
        #expect(color.blue == 1.0)
    }

    @Test func magenta() {
        let color = RgbColor.hsl(hue: 5.0 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 1.0)
        #expect(color.green == 0.0)
        #expect(color.blue == 1.0)
    }

    @Test func magentaRed() {
        let color = RgbColor.hsl(hue: 5.25 / 6.0, saturation: 1.0, lightness: 0.5)
        #expect(color.red == 1.0)
        #expect(color.green == 0.0)
        #expect(color.blue == 0.75)
    }
}
