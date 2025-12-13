import Foundation

/// A thread-safe wrapper that isolates mutable state using a lock.
final class LockIsolated<Value>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSRecursiveLock()

    init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
        self._value = try value()
    }

    /// Executes the given operation with exclusive access to the isolated value.
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
    /// Returns the isolated value with thread-safe access.
    var value: Value {
        lock.withLock {
            _value
        }
    }
}
