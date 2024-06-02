import Combine
import MetalKit

open class MetalViewController: UI.ViewController {
    public let viewLook: ViewLook = .init()
    private var renderer: Renderer?
    private var appearanceUpdatingDelay: Int = 0
    private var cancellables: Set<AnyCancellable> = []

    public var metalView: MetalView {
        self.view as! MetalView
    }

    public var isPaused: Bool {
        get { metalView.isPaused }
        set { metalView.isPaused = newValue }
    }

    open override func loadView() {
        if nibName != nil || nibBundle != nil {
            super.loadView()
        } else {
            view = MetalView(
                frame: .init(origin: .zero, size: .init(width: 256.0, height: 256.0)), device: nil)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        metalView.delegate = self
        metalView.uiDelegate = self

        updateViewLookSizes(drawableSize: metalView.drawableSize)
        viewLook.appearance = metalView.uiAppearance
    }

    #if os(macOS)

        open override func viewWillAppear() {
            super.viewWillAppear()
            view.addObserver(self, forKeyPath: "effectiveAppearance", options: [.new], context: nil)
            viewLook.appearance = metalView.uiAppearance
        }

        open override func viewDidDisappear() {
            view.removeObserver(self, forKeyPath: "effectiveAppearance")
            super.viewDidDisappear()
        }

        open override func observeValue(
            forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            if keyPath == "effectiveAppearance" {
                MainActor.assumeIsolated {
                    appearanceDidChange()
                }
            }
        }

    #endif

    public func configure(renderer: Renderer, system: MetalSystem, eventInput: EventInput) {
        metalView.device = system.device
        metalView.sampleCount = system.sampleCount

        self.renderer = renderer

        renderer.backgroundColor.sink { [weak self] color in
            self?.metalView.clearColor = color.clearColor
        }.store(in: &cancellables)

        metalView.configure()
        metalView.eventInput = eventInput
    }
}

extension MetalViewController {
    private var uiAppearance: Appearance {
        metalView.uiAppearance
    }

    private func appearanceDidChange() {
        appearanceUpdatingDelay = 2
    }

    private func updateViewLookSizes(drawableSize: CGSize) {
        viewLook.set(
            viewSize: .init(view.bounds.size), drawableSize: .init(drawableSize),
            safeAreaInsets: metalView.uiSafeAreaInsets)
    }
}

extension MetalViewController: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateViewLookSizes(drawableSize: size)
    }

    public func draw(in view: MTKView) {
        assert(Thread.isMainThread)
        renderer?.viewRender()

        if appearanceUpdatingDelay > 0 {
            appearanceUpdatingDelay -= 1
            if appearanceUpdatingDelay == 0 {
                viewLook.appearance = uiAppearance
            }
        }
    }
}

extension MetalViewController: MetalViewDelegate {
    public func metalView(_ view: MetalView, safeAreaInsetsDidChange insets: RegionInsets) {
        viewLook.setSafeAreaInsets(insets)
    }
}

extension Color {
    fileprivate var clearColor: MTLClearColor {
        .init(
            red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha.value))
    }
}

extension UIntSize {
    fileprivate init(_ cgSize: CGSize) {
        width = UInt32(cgSize.width)
        height = UInt32(cgSize.height)
    }
}
