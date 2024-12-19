import CoreFoundation

typealias Num = Int64
typealias Vector2D = SIMD2<Num>
typealias Vector3D = SIMD2<Num>

enum Direction {
  case west, north, east, south
}
let movements: [Direction: Vector2D] = [
  .west: [-1, 0], .north: [0, -1], .east: [1, 0], .south: [0, 1],
]
enum Orientation {
  case ns, we
}

func reverse(_ direction: Direction) -> Direction {
  switch direction {
  case .north: .south
  case .west: .east
  case .south: .north
  case .east: .west
  }
}

func turnRight(_ direction: Direction) -> Direction {
  switch direction {
  case .north: .east
  case .east: .south
  case .south: .west
  case .west: .north
  }
}

func turnLeft(_ direction: Direction) -> Direction {
  reverse(turnRight(direction))
}

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

  func fastFirstIndex(_ when: (Index) -> Bool) -> Index? {
    guard self.count > 0 else { return nil }
    if when(0) { return 0 }
    func find(start: Index, stepWidth: Index) -> Index? {
      if start < 0 || start >= self.count {
        nil
      } else if when(start) {
        stepWidth == 1 ? start : find(start: start - (stepWidth / 2), stepWidth: stepWidth / 2)
      } else {
        find(start: start + Swift.max(stepWidth / 2, 1), stepWidth: Swift.max(stepWidth / 2, 1))
      }
    }
    return find(start: self.count - 1, stepWidth: self.count)
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

func distance(_ v1: Vector2D, _ v2: Vector3D) -> Double {
  let d = v2 &- v1
  let s = (d &* d).wrappedSum()
  return sqrt(Double(s))
}

func cls() {
  print("\u{001B}[2J")
}

func wait(_ seconds: UInt32) -> UInt32 {
  sleep(seconds)
}

func printMap<T: CustomStringConvertible, U: FixedWidthInteger>(
  _ map: [[T]], _ path: [SIMD2<U>] = [SIMD2<Int>]()
) {
  for (y, line) in map.enumerated() {
    print(
      line.enumerated().reduce(into: "") { (result, c) in
        if path.contains([U(c.offset), U(y)]) {
          result.append("\u{001B}[0;33mO")
        } else if c.element.description == "#" {
          result.append("\u{001B}[0;31m#")
        } else {
          result.append(c.element.description)
        }
      })
  }
}

func printMap<T: RawRepresentable, U: FixedWidthInteger>(
  _ map: [[T]], _ path: [SIMD2<U>] = [SIMD2<Int>]()
)
where T.RawValue: CustomStringConvertible {
  for (y, line) in map.enumerated() {
    print(
      line.enumerated().reduce(into: "") { (result, c) in
        if path.contains([U(c.offset), U(y)]) {
          result.append("\u{001B}[0;33mO")
        } else if c.element.rawValue.description == "#" {
          result.append("\u{001B}[0;31m#")
        } else {
          result.append(c.element.rawValue.description)
        }
      })
  }
}

func printMap<T: CustomStringConvertible, U: FixedWidthInteger>(
  _ map: [T], _ path: [SIMD2<U>] = [SIMD2<Int>]()
) {
  for (y, line) in map.enumerated() {
    print(
      line.description.enumerated().reduce(into: "") { (result, c) in
        if path.contains([U(c.offset), U(y)]) {
          result.append("\u{001B}[0;33mO")
        } else if c.element == "#" {
          result.append("\u{001B}[0;31m#")
        } else {
          result.append(c.element)
        }
      })
  }
}

func printMap<T: FixedWidthInteger, U: FixedWidthInteger>(
  width: some FixedWidthInteger, height: some FixedWidthInteger,
  walls: [SIMD2<T>] = [SIMD2<Int>](),
  path: [SIMD2<U>] = [SIMD2<Int>]()
) {
  for y in 0..<height {
    print(
      (0..<width).reduce(into: "") {
        (result, x) in
        if walls.contains([T(x), T(y)]) {
          result.append("\u{001B}[0;31m#")
        } else if path.contains([U(x), U(y)]) {
          result.append("\u{001B}[0;33mO")
        } else {
          result.append("\u{001B}[0;0m.")
        }
      })
  }
}
