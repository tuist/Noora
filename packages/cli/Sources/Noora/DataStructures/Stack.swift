import Foundation

struct Stack<T> {
    private var items = [T]()
    private let maximumCapacity: UInt

    var count: Int { items.count }

    init(_ items: [T] = [], maximumCapacity: UInt) {
        self.items = items
        self.maximumCapacity = maximumCapacity
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var isFull: Bool {
        items.count == maximumCapacity
    }

    mutating func push(_ item: T) {
        if isFull {
            items.removeFirst()
        }
        items.append(item)
    }

    mutating func pop() -> T? {
        items.popLast()
    }

    func peek() -> T? {
        items.last
    }

    subscript(index: Int) -> T? {
        guard index >= 0, index < items.count else {
            return nil
        }
        return items[items.count - 1 - index]
    }
}
