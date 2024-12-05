import Foundation

let contents = read_file().split(separator: "\n\n")
let catalog = contents[0].matches(of: /(\d+)\|(\d+)/).compactMap { m in
  if case let (.some(l), .some(r)) = (Int(m.output.1), Int(m.output.2)) {
    (l, r)
  } else {
    nil
  }
}
let number_lines =
  contents[1].split(separator: "\n").compactMap { line in
    line.split(separator: ",").compactMap { s in Int(s) }
  }

enum ordering_status: Equatable {
  case ordered
  case unordered(left_index: Int, right_index: Int)
}

func part1() -> Int {
  number_lines.filter { numbers in check_ordering(numbers: numbers) == .ordered }
    .compactMap { numbers in
      numbers[(numbers.count / 2)]
    }.reduce(0, +)
}

func part2() -> Int {
  number_lines.filter { numbers in check_ordering(numbers: numbers) != .ordered }
    .compactMap(ensure_ordering).compactMap { numbers in
      numbers[(numbers.count / 2)]
    }.reduce(0, +)
}

func ensure_ordering(numbers: [Int]) -> [Int] {
  switch check_ordering(numbers: numbers) {
  case .ordered:
    numbers
  case .unordered(let left_index, let right_index):
    ensure_ordering(
      numbers: numbers_with_swap(
        numbers: numbers, left_index: left_index, right_index: right_index))
  }
}

func check_ordering(numbers: [Int]) -> ordering_status {
  for entry in catalog {
    if case let status = check_ordering(
      numbers: numbers, entry: entry), case .unordered(_, _) = status
    {
      return status
    }
  }
  return .ordered
}

func check_ordering(numbers: [Int], entry: (l: Int, r: Int)) -> ordering_status {
  guard let left_index: Int = numbers.firstIndex(of: entry.l) else { return .ordered }
  guard let right_index: Int = numbers.firstIndex(of: entry.r) else { return .ordered }
  return (left_index <= right_index)
    ? .ordered : .unordered(left_index: left_index, right_index: right_index)
}

func numbers_with_swap(numbers: [Int], left_index: Int, right_index: Int) -> [Int] {
  var new_numbers = numbers
  new_numbers.swapAt(left_index, right_index)
  return new_numbers
}

func read_file() -> String {
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
