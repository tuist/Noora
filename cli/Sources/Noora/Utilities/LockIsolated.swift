import Foundation

final class LockIsolated<Value>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSRecursiveLock()

    init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
        self._value = try value()
    }

    func withValue<T: Sendable>(
        _ operation: @Sendable (inout Value) throws -> T
    ) rethrows -> T {
        try lock.withLock {
            var value = self._value
            defer { self._value = value }
            return try operation(&value)
        }
    }
}

extension LockIsolated where Value: Sendable {
    var value: Value {
        lock.withLock {
            _value
        }
    }
}
