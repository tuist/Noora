import Foundation

struct Stack<T> {
    private var items = [T]()
    private let maximumCapacity: UInt
    
    init(maximumCapacity: UInt) {
        self.maximumCapacity = maximumCapacity
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var isFull: Bool {
        return items.count == maximumCapacity
    }
    
    mutating func push(_ item: T) {
        if isFull {
            items.removeFirst()
        }
        items.append(item)
    }
    
    mutating func pop() -> T? {
        return items.popLast()
    }
    
    func peek() -> T? {
        return items.last
    }
    
    subscript(index: Int) -> T? {
            guard index >= 0 && index < items.count else {
                return nil
            }
            return items[items.count - 1 - index]
        }
}
