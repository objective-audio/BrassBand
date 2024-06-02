import BrassBand
import Foundation

@MainActor
final class ExampleMain {
    let components: Components
    var viewLook: ViewLook { components.viewLook }
    var rootNode: Node { components.rootNode }
    var renderer: Renderer { components.renderer }
    var system: MetalSystem { components.system }
    var detector: Detector { components.detector }
    var eventInput: EventInput { components.eventInput }
    let texture: Texture
    let fontAtlas: FontAtlas
    let blurContainer: Node.RenderTargetContainer
    var blurRenderTarget: RenderTarget { blurContainer.renderTarget }

    let bg: Bg
    let softKeyboard: SoftKeyboard
    let bigButton: BigButton
    let bigButtonText: BigButtonText
    let touchCircle: TouchCircle
    let cursor: RollingCursor
    let batchNode: Node
    let hoverPlanes: HoverPlanes
    let justifiedPoints: JustifiedPoints
    let inputtedText: InputtedText
    let modifierText: ModifierText
    var blurNode: Node { blurContainer.node }
    let blurPlane: RectPlane
    let dynamicMeshDataPlane = RectPlane(rectCount: 1)
    let staticMeshDataNodeContainer = Node.ContentContainer()
    let textureElementsPlane = RectPlane(rectCount: 2, indexCount: 1)
    private var touchTracker: TouchTracker!

    private var task: Task<(), Never>?
    private var cancellables: Set<AnyCancellable> = []

    init(viewLook: ViewLook, system: MetalSystem) {
        components = .init(viewLook: viewLook, system: system)
        texture = .init(pointSize: .init(width: 1024, height: 1024), scaleFactorProvider: viewLook)
        fontAtlas = .init(
            fontName: "TrebuchetMS-Bold", fontSize: 26.0,
            words: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890+-:",
            texture: texture)

        bg = .init(viewLook: viewLook)
        softKeyboard = .init(
            fontAtlas: fontAtlas, eventInput: components.eventInput,
            rootAction: components.rootAction, detector: components.detector,
            renderer: components.renderer, safeAreaGuide: viewLook.safeAreaLayoutGuide)
        bigButton = .init(
            eventInput: components.eventInput, detector: components.detector,
            renderer: components.renderer, texture: texture)
        bigButtonText = .init(fontAtlas: fontAtlas)
        touchCircle = .init(
            eventInput: components.eventInput, rootAction: components.rootAction, texture: texture)
        cursor = .init(eventInput: components.eventInput, rootAction: components.rootAction)
        batchNode = .batch
        hoverPlanes = HoverPlanes(components: components)
        justifiedPoints = .init(layoutRegionSource: components.viewLook.viewLayoutGuide)
        inputtedText = .init(
            fontAtlas: fontAtlas, eventInput: components.eventInput,
            safeAreaGuide: viewLook.safeAreaLayoutGuide)
        modifierText = .init(
            fontAtlas: fontAtlas, eventInput: components.eventInput,
            safeAreaGuide: viewLook.safeAreaLayoutGuide,
            bottomGuide: viewLook.safeAreaLayoutGuide.bottomGuide)
        blurContainer = .init(scaleFactorProvider: viewLook)
        blurPlane = .init(rectCount: 1)

        setup()
        setupHierarchy()
    }

    deinit {
        task?.cancel()
    }

    private func setupHierarchy() {
        batchNode.appendSubNode(hoverPlanes.node)
        batchNode.appendSubNode(justifiedPoints.node)

        bigButton.node.appendSubNode(bigButtonText.node)

        blurNode.appendSubNode(blurPlane.node)

        rootNode.appendSubNode(bg.node)
        rootNode.appendSubNode(blurNode)
        rootNode.appendSubNode(softKeyboard.node)
        rootNode.appendSubNode(bigButton.node)
        rootNode.appendSubNode(batchNode)
        rootNode.appendSubNode(touchCircle.node)
        rootNode.appendSubNode(cursor.node)
        rootNode.appendSubNode(inputtedText.node)
        rootNode.appendSubNode(modifierText.node)

        rootNode.appendSubNode(dynamicMeshDataPlane.node)
        rootNode.appendSubNode(staticMeshDataNodeContainer.node)
        rootNode.appendSubNode(textureElementsPlane.node)
    }

    private func setup() {
        viewLook.background.color = .init(rgb: .red, alpha: .one)

        setupDynamicMeshData: do {
            dynamicMeshDataPlane.content.color = .init(rgb: .green, alpha: .init(value: 0.2))
            dynamicMeshDataPlane.data.setRectPosition(
                .init(center: .zero, size: .init(width: 100, height: 100)), rectIndex: 0)

            task = Task { [plane = dynamicMeshDataPlane] in
                while true {
                    try? await Task.sleep(for: .seconds(0.2))

                    let width = Float.random(in: 10..<200)

                    await plane.data.writeVerticesAsync { rect in
                        let region = Region(center: .zero, size: .init(width: width, height: width))
                        rect[0].setPositions(region.positions)
                    }
                }
            }
        }

        setupStaticMeshData: do {
            Task(priority: .low) {
                let meshVertexData = await StaticMeshVertexData(count: 4) {
                    $0.withMemoryRebound(to: Vertex2dRect.self) {
                        $0[0].setPositions(
                            .init(.init(center: .zero, size: .init(width: 200, height: 2))))
                    }
                }
                let meshIndexData = await StaticMeshIndexData(count: 6) {
                    $0.withMemoryRebound(to: Index2dRect.self) {
                        $0[0].setAll(first: 0)
                    }
                }
                let mesh = Mesh(
                    vertexData: meshVertexData.rawMeshData, indexData: meshIndexData.rawMeshData)

                staticMeshDataNodeContainer.content.color.rgb = .cyan
                staticMeshDataNodeContainer.content.meshes = [mesh]
            }
        }

        setupTextureElements: do {
            let meshSize = UIntSize(width: 100, height: 50)
            let rectPlane = textureElementsPlane
            let node = rectPlane.node

            node.geometry.position = .init(x: 50, y: 25)
            node.geometry.scale = .init(meshSize)
            rectPlane.content.meshes[0].texture = texture

            rectPlane.data.setRectPosition(.init(center: .zero, size: .one), rectIndex: 0)
            rectPlane.data.setRectPosition(.init(center: .zero, size: .one), rectIndex: 1)

            let element0 = texture.addElement(
                size: meshSize,
                handler: { context in
                    context.setFillColor(Color(rgb: .orange, alpha: .init(value: 0.5)).cgColor)
                    context.fill(.init(origin: .zero, size: Size(meshSize).cgSize))
                })

            rectPlane.data.bindRectTexcoords(element: element0, rectIndex: 0).store(
                in: &cancellables)

            let element1 = texture.addElement(
                size: meshSize,
                handler: { context in
                    context.setFillColor(Color(rgb: .black, alpha: .init(value: 0.2)).cgColor)
                    context.fill(.init(origin: .zero, size: Size(meshSize).cgSize))
                })

            rectPlane.data.bindRectTexcoords(element: element1, rectIndex: 1).store(
                in: &cancellables)

            let collider = Collider(
                shape: RectShape(rect: .init(center: .zero, size: .one))
            )
            node.colliders = [collider]

            let touchTracker = TouchTracker(components: components, node: node)
            self.touchTracker = touchTracker
            touchTracker.publisher.sink { _ in
                let rectIndex = (touchTracker.tracking != nil) ? 1 : 0
                rectPlane.data.setRectIndices([(indexIndex: 0, vertexIndex: rectIndex)])
            }.store(in: &cancellables)
        }

        setupSoftKeyboard: do {
            softKeyboard.keyPublisher.sink { [weak self] key in
                self?.inputtedText.appendText(key)
            }.store(in: &cancellables)
        }

        setupBigButton: do {
            let bigButtonRegion = bigButton.button.layoutGuide.region

            bigButtonText.strings.preferredFrame = Region(
                horizontalRange: .init(
                    location: -bigButtonRegion.size.width * 0.5, length: bigButtonRegion.size.width),
                verticalRange: .zero)

            bigButton.button.publisher.sink { [weak bigButtonText] context in
                bigButtonText?.setStatus(context.phase)
            }.store(in: &cancellables)

            let action = Action.Translation(
                target: bigButton.node, beginPosition: .zero, endPosition: .init(x: 32.0, y: 0.0),
                duration: .seconds(5), loop: .infinity,
                valueTransformer: { sinf(Float.pi * 2.0 * $0) }
            )
            components.rootAction.insert(action)
        }

        setupBlur: do {
            let blur = Blur()
            blurRenderTarget.effect = blur.effect

            blurPlane.data.setRectPosition(
                .init(center: .init(repeating: -100.0), size: .init(repeating: 50.0)), rectIndex: 0)
            blurPlane.content.color = .init(rgb: .cyan, alpha: .one)

            viewLook.viewLayoutGuide.regionPublisher.sink { [blurRenderTarget] region in
                blurRenderTarget.layoutGuide.region = region
            }.store(in: &cancellables)

            let blurAction = Action.Continuous(
                duration: .seconds(5), loop: .infinity,
                valueUpdater: { value in
                    blur.sigma = Double(value) * 20.0
                },
                valueTransformer: Transformer.pingPong
            )
            components.rootAction.insert(blurAction)

            let rotateAction = Action.Rotation(
                target: blurPlane.node, beginAngle: .zero,
                endAngle: .init(degrees: 360.0),
                duration: .seconds(3), loop: .infinity
            )
            components.rootAction.insert(rotateAction)
        }

        setupDrawcall: do {
            renderer.didRender.throttle(
                for: .seconds(1), scheduler: DispatchQueue.main, latest: true
            ).sink { [weak self] _ in
                let drawcall = (self?.system.lastEncodedMeshCount).flatMap(String.init) ?? "-"
                print("drawcall:\(drawcall)")
            }.store(in: &cancellables)
        }
    }
}
