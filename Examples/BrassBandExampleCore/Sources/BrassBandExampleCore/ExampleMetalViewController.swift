import BrassBand

public final class ExampleMetalViewController: MetalViewController {
    private var main: ExampleMain?

    public override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = MTLCreateSystemDefaultDevice(),
            let system = MetalSystem(device: device, view: metalView)
        else {
            return
        }

        let main = ExampleMain(viewLook: viewLook, system: system)
        self.main = main

        configure(renderer: main.renderer, system: system, eventInput: main.eventInput)
    }
}
