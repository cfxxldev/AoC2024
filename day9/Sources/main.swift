import Foundation

extension Sequence where Element: Hashable {
  func uniqued() -> [Element] {
    var set = Set<Element>()
    return filter { set.insert($0).inserted }
  }
}

extension Sequence where Element: Sequence {
  func flattened() -> [Element.Element] {
    return reduce([], +)
  }
  func toArray() -> [[Element.Element]] {
    return compactMap { e in
      e.toArray()
    }
  }
}

extension Sequence {
  func slide(_ maxLen: Int) -> [[Element]] {
    enumerated().compactMap { (index, _) in
      self.dropFirst(index).prefix(maxLen).toArray()
    }
  }

  func slide(exactLen: Int) -> [[Element]] {
    slide(exactLen).filter { $0.count == exactLen }
  }

  func chunk(_ maxLen: Int) -> [[Element]] {
    enumerated().filter { (index, _) in index % maxLen == 0 }.compactMap { (index, _) in
      self.dropFirst(index).prefix(maxLen).toArray()
    }
  }

  func chunk(exactLen: Int) -> [[Element]] {
    chunk(exactLen).filter { $0.count == exactLen }
  }

  func toArray() -> [Element] {
    Array(self)
  }
}

func toInt(value: Character) -> Int? {
  Int(String(value))
}

func toInt(value: any StringProtocol) -> Int? {
  Int(value)
}

let fileContent = readFile()
let splitLines = fileContent.split(separator: "\n")

func readFile() -> String {
  do {
    return try String(
      contentsOf: URL(filePath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("input"), encoding: .ascii)
  } catch {
    print(error)
    exit(1)
  }
}

print("part1: \(part1())")
print("part2: \(part2())")
