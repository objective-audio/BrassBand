import Testing

@testable import BrassBand

@MainActor
struct RenderTargetTests {
    @Test
    func renderTargetContainer() {
        let scaleFactor = ScaleFactorProviderStub()
        let container = Node.RenderTargetContainer(scaleFactorProvider: scaleFactor)

        #expect(container.node.renderTarget != nil)
    }

    @Test
    func effectProperty() {
        let scaleFactor = ScaleFactorProviderStub()
        let container = Node.RenderTargetContainer(scaleFactorProvider: scaleFactor)
        let renderTarget = container.renderTarget

        // 新しいエフェクトを設定
        let newEffect = Effect()
        renderTarget.effect = newEffect

        // 設定したエフェクトが反映されていることを確認
        #expect(renderTarget.effect === newEffect)

        // 変更を確認（内部でsetTexturesToEffectが呼ばれたことを確認）
        var updates = TreeUpdates()
        renderTarget.fetchUpdates(&updates)
        #expect(updates.renderTargetUpdates.contains(.effect))
    }

    @Test
    func effectUpdatesOnChange() {
        let scaleFactor = ScaleFactorProviderStub()
        let container = Node.RenderTargetContainer(scaleFactorProvider: scaleFactor)
        let renderTarget = container.renderTarget

        // 初期状態で内部更新が行われていることを確認
        var initialUpdates = TreeUpdates()
        renderTarget.fetchUpdates(&initialUpdates)
        #expect(initialUpdates.renderTargetUpdates.contains(.effect))

        // 更新をクリア
        renderTarget.clearUpdates()

        // クリア後は更新フラグが立っていないことを確認
        var clearedUpdates = TreeUpdates()
        renderTarget.fetchUpdates(&clearedUpdates)
        #expect(!clearedUpdates.renderTargetUpdates.contains(.effect))

        // 同じエフェクトインスタンスを再設定した場合、更新が発生しないことを確認
        let currentEffect = renderTarget.effect
        renderTarget.effect = currentEffect

        var noChangeUpdates = TreeUpdates()
        renderTarget.fetchUpdates(&noChangeUpdates)
        #expect(!noChangeUpdates.renderTargetUpdates.contains(.effect))

        // 新しいエフェクトを設定した場合、更新が発生することを確認
        let newEffect = Effect()
        renderTarget.effect = newEffect

        var changedUpdates = TreeUpdates()
        renderTarget.fetchUpdates(&changedUpdates)
        #expect(changedUpdates.renderTargetUpdates.contains(.effect))
    }
}
