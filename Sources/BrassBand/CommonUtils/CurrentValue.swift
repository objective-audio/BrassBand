import Combine

@propertyWrapper public final class CurrentValue<Value> {
    public init(wrappedValue: Value) {
        self.projectedValue = .init(wrappedValue)
    }

    public var wrappedValue: Value {
        get { projectedValue.value }
        set { projectedValue.value = newValue }
    }

    public let projectedValue: CurrentValueSubject<Value, Never>
}
