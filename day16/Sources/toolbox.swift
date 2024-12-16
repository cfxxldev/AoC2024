extension Sequence where Element: Hashable {
  func uniqued() -> some Sequence<Element> {
    var set = Set<Element>()
    return filter { set.insert($0).inserted }
  }
}

extension Sequence where Element: Sequence {
  func flattened() -> [Element.Element] {
    return reduce([], +)
  }
}

extension Sequence where Element: AdditiveArithmetic {
  func flattened() -> Element {
    return reduce(Element.zero, +)
  }
}

extension Optional {
  func flattened() -> [Wrapped] {
    return self != nil ? [self!] : []
  }
}

extension Sequence {
  func flattened<T>() -> [T] where T? == Element {
    return compactMap { $0 }
  }

  func slide(_ maxLen: Int) -> [ArraySlice<Element>] {
    enumerated().compactMap { (index, _) in
      ArraySlice(self.dropFirst(index).prefix(maxLen))
    }
  }

  func slide(exactLen: Int) -> [ArraySlice<Element>] {
    slide(exactLen).filter { $0.count == exactLen }
  }

  func chunk(_ maxLen: Int) -> [ArraySlice<Element>] {
    enumerated().filter { (index, _) in index % maxLen == 0 }.compactMap { (index, _) in
      ArraySlice(self.dropFirst(index).prefix(maxLen))
    }
  }

  func chunk(exactLen: Int) -> [ArraySlice<Element>] {
    chunk(exactLen).filter { $0.count == exactLen }
  }

  func swappedAt(_ leftIndex: Array.Index, _ rightIndex: Array.Index, count: Int) -> [Element] {
    var newArray = self.toArray()
    newArray.swapAt(leftIndex, rightIndex, count: count)
    return newArray
  }

  func swappedAt(_ leftIndex: Array.Index, _ rightIndex: Array.Index) -> [Element] {
    swappedAt(leftIndex, rightIndex, count: 1)
  }

  func toArray() -> [Element] {
    Array(self)
  }
}

extension Array {
  mutating func swapAt(_ leftIndex: Index, _ rightIndex: Index, count: Int) {
    for i in 0..<count {
      self.swapAt(leftIndex + i, rightIndex + i)
    }
  }
}

func toIntFunc<T: FixedWidthInteger, U: LosslessStringConvertible>(_ returnType: T.Type) -> (U) ->
  T?
{
  { value in T(String(value)) }
}

func toInt<T: FixedWidthInteger, U: LosslessStringConvertible>(_ value: U, returnType: T.Type) -> T?
{
  toIntFunc(returnType)(value)
}

func printMap<T: LosslessStringConvertible>(_ map: [[T]]) {
  for line in map {
    print(line.reduce("") { result, c in result + String(c) })
  }
}

func printMap<T: CustomStringConvertible>(_ map: [[T]]) {
  for line in map {
    print(line.reduce("") { result, c in result + c.description })
  }
}

func printMap<T: LosslessStringConvertible>(_ map: [T]) {
  for line in map {
    print(line)
  }
}
