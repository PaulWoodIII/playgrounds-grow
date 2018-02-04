//: Trees and Design Patterns for Trees

import Foundation

class Tree<T : Comparable> {
  var value: T
  var parent: Tree?
  var left: Tree?
  var right: Tree?
  
  var strategy: Strategy<T> = .none {
    didSet(newValue) {
      // recreate the Tree using the new Strategy
      var newTree = Tree<T>(self.toArray())
      self.value = newTree.value
      self.parent = newTree.parent
      self.left = newTree.left
      newTree.left?.parent = self
      self.right = newTree.right
      newTree.right?.parent = self
    }
  }
  
  init(value: T) {
    self.value = value
  }
  
  public var isRoot: Bool {
    return parent != nil
  }
  
  public var isLeaf: Bool {
    return left == nil && right == nil
  }
  
  public var isLeftChild: Bool {
    return parent?.left === self
  }
  
  public var isRightChild: Bool {
    return parent?.right === self
  }
  
  public var hasLeftChild: Bool {
    return left != nil
  }
  
  public var hasRightChild: Bool {
    return right != nil
  }
  
  public var hasAnyChild: Bool {
    return left != nil || right != nil
  }
  
  public var hasBothChildren: Bool {
    return left != nil && right != nil
  }
  
  public var count: Int {
    return (left?.count ?? 0) + 1 + (right?.count ?? 0)
  }
  
  
  func insert(value: T) {
    strategy.insert(value: value, tree: self)
  }
  
  func remove(value: T) {
    strategy.remove(value: value, tree: self)
  }

}

extension Tree {
  public convenience init(_ array: [T]) {
    precondition(array.count > 0)
    self.init(value: array.first!)
    for v in array.dropFirst() {
      insert(value: v)
    }
  }
}

extension Tree {
  func search(value: T) -> Tree? {
    if value == self.value {
      return self
    } else if value > self.value {
      return right?.search(value: value)
    } else  {
      return left?.search(value: value)
    }
  }
  
  func contains(value: T) -> Bool {
    return search(value: value) != nil
  }
}

extension Tree: CustomStringConvertible {
  public var description: String {
    var s = ""
    if let left = left {
      s += "\(left.description)<- "
    }
    s += "\(value)"
    if let right = right {
      s += " ->\(right.description)"
    }
    return s
  }
}

extension Tree { //Traversal
  public func traverseInOrder(process: (T) -> Void) {
    left?.traverseInOrder(process: process)
    process(value)
    right?.traverseInOrder(process: process)
  }
  public func traversePreOrder(process: (T) -> Void) {
    process(value)
    left?.traversePreOrder(process: process)
    right?.traversePreOrder(process: process)
    
  }
  public func traversePostOrder(process: (T) -> Void) {
    right?.traversePostOrder(process: process)
    process(value)
    left?.traversePostOrder(process: process)
  }
  
  public func map(formula: (T) -> T) -> [T] {
    var a = [T]()
    if let left = left { a += left.map(formula: formula) }
    a.append(formula(value))
    if let right = right { a += right.map(formula: formula) }
    return a
  }
  
  public func filter(_ formula: (T) -> Bool ) -> [T] {
    var a = [T]()
    if let left = left{ a+=left.filter(formula) }
    if formula(value) { a.append( value ) }
    if let right = right { a += right.filter(formula) }
    return a
  }
  
  public func reduce<Result>(_ initialResult: Result,
                             _ nextPartialResult: (Result, T) throws -> Result) rethrows -> Result {
    var a = initialResult
    if let left = left {
      try? a = left.reduce(a, nextPartialResult)
    }
    try? a = nextPartialResult(a, value)
    if let right = right {
      try? a =  right.reduce(a, nextPartialResult)
    }
    return a
  }
  
  public func toArray() -> [T] {
    return self.map(formula: { return $0 })
  }
}

extension Tree { // Removal helpers
  fileprivate func reconnectParentToNode(node: Tree?) {
    if let parent = parent {
      if isLeftChild {
        parent.left = node
      } else {
        parent.right = node
      }
    }
    node?.parent = parent
  }
  
  public func minimum() -> Tree {
    var node = self
    while let next = node.left {
      node = next
    }
    return node
  }
  
  public func maximum() -> Tree {
    var node = self
    while let next = node.right {
      node = next
    }
    return node
  }
}

enum Strategy <T: Comparable>  {
  case none
  case avl
  case rbt
  
  @discardableResult
  func insert(value: T, tree: Tree<T>) -> Tree<T>? {
    switch self {
//    case .none:
//      return None.insert(value, tree)
    default:
      return None.insert(value: value, tree: tree)
    }
  }
  
  @discardableResult
  func remove(value: T, tree: Tree<T>) -> Tree<T>? {
    switch self {
      //    case .none:
    //      return None.insert(value, tree)
    default:
      if let node = tree.search(value: value) {
        return None.remove(node: node)
      }
      return nil
    }
  }
  
  struct None<T: Comparable> {
    /// Returns the node added
    @discardableResult
    static func insert(value: T, tree: Tree<T>) -> Tree<T>? {
      if tree.value == value {
        return nil
      }
      if value < tree.value {
        if let left = tree.left {
          return insert(value: value, tree: left)
        } else {
          tree.left = Tree(value: value)
          tree.left?.parent = tree
          return tree.left
        }
      } else {
        if let right = tree.right {
          return insert(value: value, tree: right)
        } else {
          tree.right = Tree(value: value)
          tree.right?.parent = tree
          return tree.right
        }
      }
    }
    
    // TODO Finish this implementation
    @discardableResult
    static public func remove(node: Tree<T>) -> Tree<T>? {
      let replacement: Tree<T>?
      
      // Replacement for current node can be either biggest one on the left or
      // smallest one on the right, whichever is not nil
      if let right = node.right {
        replacement = right.minimum()
      } else if let left = node.left {
        replacement = left.maximum()
      } else {
        replacement = nil
      }
      
      if let replacement = replacement {
        remove(node: replacement)
      }
      
      // Place the replacement on current node's position
      replacement?.right = node.right
      replacement?.left = node.left
      node.right?.parent = replacement
      node.left?.parent = replacement
      node.reconnectParentToNode(node: replacement)
      
      // The current node is no longer part of the tree, so clean it up.
      node.parent = nil
      node.left = nil
      node.right = nil
      
      return replacement
    }
  }
  
  struct AVL<T: Comparable> {
    static func insert(value: T, tree: Tree<T>) {
      Strategy.None.insert(value: value, tree: tree)
      //balance(tree)
    }
  }
  
}

let sequence = [3,2,1,4,5]
print(sequence)
let tree = Tree(sequence)
tree.search(value: 1)
tree.search(value: 5)

print("traverseInOrder")
tree.traverseInOrder { value in print(value) }
print("traversePreOrder")
tree.traversePreOrder { value in print(value) }
print("traversePostOrder")
tree.traversePostOrder { value in print(value) }

print("mapping")
let plus1 = tree.map(formula: { return $0+1 })

print("filtering")
let justOdds = tree.filter { v -> Bool in
  return v % 2 != 0
}
print(justOdds)

tree.reduce(0, +)
tree.contains(value: 1)
tree.remove(value: 3)
tree.remove(value: 1)
tree
