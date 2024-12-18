import CoreFoundation

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

func toIntFunc<T: FixedWidthInteger, U: LosslessStringConvertible>(_ returnType: T.Type = T.self)
  -> (U) ->
  T?
{
  { value in T(String(value)) }
}

func toInt<T: FixedWidthInteger, U: LosslessStringConvertible>(
  _ value: U, returnType: T.Type = T.self
) -> T? {
  toIntFunc(returnType)(value)
}

func cls() {
  print("\u{001B}[2J")
}

func wait(_ seconds: UInt32) -> UInt32 {
  sleep(seconds)
}

func printMap<T: CustomStringConvertible>(_ map: [[T]], _ path: [SIMD2<Int>] = []) {
  for (y, line) in map.enumerated() {
    print(
      line.enumerated().reduce("") { (result, c) in
        result + (path.contains([c.offset, y]) ? "*" : c.element.description)
      })
  }
}

func printMap<T: RawRepresentable>(_ map: [[T]], _ path: [SIMD2<Int>] = [])
where T.RawValue: CustomStringConvertible {
  for (y, line) in map.enumerated() {
    print(
      line.enumerated().reduce("") { (result, c) in
        result + (path.contains([c.offset, y]) ? "*" : c.element.rawValue.description)
      })
  }
}

func printMap<T: CustomStringConvertible>(_ map: [T], _ path: [SIMD2<Int>] = []) {
  for (y, line) in map.enumerated() {
    print(
      line.description.enumerated().reduce("") { (result, c) -> String in
        result + (path.contains([c.offset, y]) ? "*" : String(c.element))
      })
  }
}