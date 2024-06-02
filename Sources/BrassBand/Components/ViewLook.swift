import Foundation
import simd

@MainActor
public final class ViewLook {
    public private(set) var viewSize: UIntSize = .zero
    public private(set) var drawableSize: UIntSize = .zero
    public private(set) var safeAreaInsets: RegionInsets = .zero
    public private(set) var projectionMatrix: simd_float4x4 = matrix_identity_float4x4

    public private(set) var scaleFactor: Double = 0.0
    public var scaleFactorPublisher: AnyPublisher<Double, Never> {
        $scaleFactorNotify.eraseToAnyPublisher()
    }
    @CurrentValue
    private var scaleFactorNotify: Double = 0.0

    @CurrentValue
    public internal(set) var appearance: Appearance = .normal

    public let viewLayoutGuide: LayoutRegionGuide = .init()
    public let safeAreaLayoutGuide: LayoutRegionGuide = .init()

    public let background: Background = .init()

    public func set(
        viewSize: UIntSize, drawableSize: UIntSize, safeAreaInsets: RegionInsets
    ) {
        let viewSizeResult = update(viewSize: viewSize, drawableSize: drawableSize)
        let scaleResult = updateScaleFactor()
        let safeAreaResult = updateSafeAreaInsets(safeAreaInsets)

        if viewSizeResult || safeAreaResult {
            updateViewLayoutGuide()
            updateSafeAreaLayoutGuide()

            if scaleResult {
                scaleFactorNotify = scaleFactor
            }
        }
    }

    public func setSafeAreaInsets(_ insets: RegionInsets) {
        if updateSafeAreaInsets(insets) {
            updateSafeAreaLayoutGuide()
        }
    }
}

extension ViewLook {
    private func update(viewSize: UIntSize, drawableSize: UIntSize) -> Bool {
        if viewSize == self.viewSize, drawableSize == self.drawableSize {
            return false
        } else {
            self.viewSize = viewSize
            self.drawableSize = drawableSize

            let halfWidth = Float(viewSize.width) * 0.5
            let halfHeight = Float(viewSize.height) * 0.5

            projectionMatrix = simd_float4x4.ortho(
                left: -halfWidth, right: halfWidth, bottom: -halfHeight, top: halfHeight,
                near: -1.0, far: 1.0)

            return true
        }
    }

    private func updateScaleFactor() -> Bool {
        let prevScaleFactor = scaleFactor

        if viewSize.width > 0, drawableSize.width > 0 {
            scaleFactor = Double(drawableSize.width) / Double(viewSize.width)
        } else if viewSize.height > 0 && drawableSize.height > 0 {
            scaleFactor = Double(drawableSize.height) / Double(viewSize.height)
        } else {
            scaleFactor = 0.0
        }

        if fabs(scaleFactor - prevScaleFactor) < Double.ulpOfOne {
            return false
        } else {
            return true
        }
    }

    private func updateSafeAreaInsets(_ insets: RegionInsets) -> Bool {
        if insets == safeAreaInsets {
            return false
        } else {
            safeAreaInsets = insets
            return true
        }
    }

    private func updateViewLayoutGuide() {
        viewLayoutGuide.region = .init(
            origin: .init(x: -Float(viewSize.width) * 0.5, y: -Float(viewSize.height) * 0.5),
            size: .init(viewSize))
    }

    private func updateSafeAreaLayoutGuide() {
        let viewWidth = Float(viewSize.width)
        let viewHeight = Float(viewSize.height)
        let originX = -viewWidth * 0.5 + safeAreaInsets.left
        let originY = -viewHeight * 0.5 + safeAreaInsets.bottom
        let width = viewWidth - safeAreaInsets.left - safeAreaInsets.right
        let height = viewHeight - safeAreaInsets.bottom - safeAreaInsets.top
        safeAreaLayoutGuide.region = .init(
            origin: .init(x: originX, y: originY), size: .init(width: width, height: height))
    }
}

extension ViewLook: Node.Parent {
    public var treeMatrix: simd_float4x4 { projectionMatrix }

    public func removeSubNode(_ subNode: Node) {
        fatalError()
    }
}

extension ViewLook: Renderer.ViewLook {}
