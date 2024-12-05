import Foundation

let contents = readFile().split(separator: "\n\n")
let catalog = contents[0].matches(of: /(\d+)\|(\d+)/).compactMap { m in
  if case (.some(let leftIndex), .some(let rightIndex)) = (Int(m.output.1), Int(m.output.2)) {
    (leftIndex, rightIndex)
  } else {
    nil
  }
}
let numberLines =
  contents[1].split(separator: "\n").compactMap { line in
    line.split(separator: ",").compactMap { s in Int(s) }
  }

enum OrderingStatus: Equatable {
  case ordered
  case unordered(leftIndex: Int, rightIndex: Int)
}

func part1() -> Int {
  numberLines.filter { numbers in checkOrdering(numbers: numbers) == .ordered }
    .compactMap { numbers in
      numbers[(numbers.count / 2)]
    }.reduce(0, +)
}

func part2() -> Int {
  numberLines.filter { numbers in checkOrdering(numbers: numbers) != .ordered }
    .compactMap(ensureOrdering).compactMap { numbers in
      numbers[(numbers.count / 2)]
    }.reduce(0, +)
}

func ensureOrdering(numbers: [Int]) -> [Int] {
  switch checkOrdering(numbers: numbers) {
  case .ordered:
    numbers
  case .unordered(let leftIndex, let rightIndex):
    ensureOrdering(
      numbers: numbersWithSwap(
        numbers: numbers, leftIndex: leftIndex, rightIndex: rightIndex))
  }
}

func checkOrdering(numbers: [Int]) -> OrderingStatus {
  for entry in catalog {
    if case let status = checkOrdering(
      numbers: numbers, entry: entry), case .unordered(_, _) = status
    {
      return status
    }
  }
  return .ordered
}

func checkOrdering(numbers: [Int], entry: (l: Int, r: Int)) -> OrderingStatus {
  guard let leftIndex: Int = numbers.firstIndex(of: entry.l) else { return .ordered }
  guard let rightIndex: Int = numbers.firstIndex(of: entry.r) else { return .ordered }
  return (leftIndex <= rightIndex)
    ? .ordered : .unordered(leftIndex: leftIndex, rightIndex: rightIndex)
}

func numbersWithSwap(numbers: [Int], leftIndex: Int, rightIndex: Int) -> [Int] {
  var newNumbers = numbers
  newNumbers.swapAt(leftIndex, rightIndex)
  return newNumbers
}

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
