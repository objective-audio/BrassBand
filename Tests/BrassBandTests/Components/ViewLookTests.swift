import Testing

@testable import BrassBand

@MainActor
struct ViewLookTests {
    @Test func setViewSize() throws {
        let viewLook = ViewLook()

        #expect(viewLook.viewSize == .zero)
        #expect(viewLook.drawableSize == .zero)

        viewLook.set(
            viewSize: .init(width: 256, height: 128), drawableSize: .init(width: 512, height: 256),
            safeAreaInsets: .zero)

        #expect(viewLook.scaleFactor == 2.0)
        #expect(viewLook.viewSize == .init(width: 256, height: 128))
        #expect(viewLook.drawableSize == .init(width: 512, height: 256))
    }

    @Test func setSafeAreaInsets() throws {
        let viewLook = ViewLook()

        #expect(viewLook.viewSize == .zero)
        #expect(viewLook.safeAreaInsets == .zero)

        viewLook.set(
            viewSize: .init(width: 256, height: 128), drawableSize: .init(width: 512, height: 256),
            safeAreaInsets: .init(left: 1.0, right: 2.0, bottom: 3.0, top: 4.0))

        #expect(viewLook.viewSize == .init(width: 256, height: 128))
        #expect(viewLook.safeAreaInsets == .init(left: 1.0, right: 2.0, bottom: 3.0, top: 4.0))

        viewLook.setSafeAreaInsets(.init(left: 4.0, right: 3.0, bottom: 2.0, top: 1.0))

        #expect(viewLook.safeAreaInsets == .init(left: 4.0, right: 3.0, bottom: 2.0, top: 1.0))
    }

    @Test func testObserveViewLayoutGuide() throws {
        let viewLook = ViewLook()

        #expect(viewLook.viewSize == .zero)

        viewLook.set(
            viewSize: .init(width: 16, height: 16), drawableSize: .init(width: 32, height: 32),
            safeAreaInsets: .zero)

        #expect(viewLook.viewSize == .init(width: 16, height: 16))

        var called: [Region] = []

        let canceller = viewLook.viewLayoutGuide.regionPublisher.sink { region in
            called.append(region)
        }

        viewLook.set(
            viewSize: .init(width: 32, height: 32), drawableSize: .init(width: 64, height: 64),
            safeAreaInsets: .zero)

        #expect(called.count == 2)
        #expect(called[0] == .init(origin: .init(x: -8, y: -8), size: .init(width: 16, height: 16)))
        #expect(
            called[1] == .init(origin: .init(x: -16, y: -16), size: .init(width: 32, height: 32)))
        #expect(viewLook.viewSize == .init(width: 32, height: 32))

        canceller.cancel()
    }

    @Test func testObserveSafeAreaLayoutGuide() throws {
        let viewLook = ViewLook()

        #expect(viewLook.safeAreaLayoutGuide.region == .zero)

        viewLook.set(
            viewSize: .init(width: 16, height: 16), drawableSize: .init(width: 32, height: 32),
            safeAreaInsets: .zero)

        var called: [Region] = []

        let canceller = viewLook.safeAreaLayoutGuide.regionPublisher.sink { region in
            called.append(region)
        }

        #expect(called.count == 1)
        #expect(called[0] == .init(origin: .init(x: -8, y: -8), size: .init(width: 16, height: 16)))

        viewLook.set(
            viewSize: .init(width: 32, height: 32), drawableSize: .init(width: 64, height: 64),
            safeAreaInsets: .init(left: 2, right: 2, bottom: 2, top: 2))

        #expect(called.count == 2)
        #expect(
            called[1] == .init(origin: .init(x: -14, y: -14), size: .init(width: 28, height: 28)))

        viewLook.setSafeAreaInsets(.init(left: 4, right: 4, bottom: 4, top: 4))

        #expect(called.count == 3)
        #expect(
            called[2] == .init(origin: .init(x: -12, y: -12), size: .init(width: 24, height: 24)))

        canceller.cancel()
    }

    @Test func observeScaleFactor() throws {
        let viewLook = ViewLook()

        var received: Double = 0.0

        let canceller = viewLook.scaleFactorPublisher.sink {
            received = $0
        }

        #expect(received == 0.0)

        viewLook.set(
            viewSize: .init(width: 256, height: 128), drawableSize: .init(width: 512, height: 256),
            safeAreaInsets: .zero)

        #expect(received == 2.0)

        canceller.cancel()
    }

    @Test func projectionMatrixAndTreeMatrix() {
        let viewLook = ViewLook()

        #expect(viewLook.projectionMatrix == matrix_identity_float4x4)
        #expect(viewLook.treeMatrix == matrix_identity_float4x4)

        viewLook.set(
            viewSize: .init(width: 8, height: 8), drawableSize: .init(width: 8, height: 8),
            safeAreaInsets: .zero)

        let expected = simd_float4x4.ortho(
            left: -4.0, right: 4.0, bottom: -4.0, top: 4.0,
            near: -1.0, far: 1.0)

        #expect(viewLook.projectionMatrix == expected)
        #expect(viewLook.treeMatrix == expected)
    }
}
