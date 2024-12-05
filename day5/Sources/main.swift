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

enum order_status: Equatable {
    case ordered
    case unordered(left_index: Int, right_index: Int)
}

func part1() -> Int {
    number_lines.filter { numbers in check_ordering(numbers: numbers) == .ordered }
        .compactMap { numbers in
            numbers[(numbers.count / 2)]
        }.reduce(0) { sum, value in
            sum + value
        }
}

func part2() -> Int {
    number_lines.filter { numbers in check_ordering(numbers: numbers) != .ordered }
        .compactMap(ensure_ordering).compactMap { numbers in
            numbers[(numbers.count / 2)]
        }.reduce(0) { sum, value in
            sum + value
        }
}

func ensure_ordering(numbers: [Int]) -> [Int] {
    switch check_ordering(numbers: numbers) {
    case .ordered:
        return numbers
    case .unordered(let left_index, let right_index):
        var new_numbers = numbers
        new_numbers.swapAt(left_index, right_index)
        return ensure_ordering(numbers: new_numbers)
    }
}

func check_ordering(numbers: [Int]) -> order_status {
    for entry in catalog {
        if case let .unordered(left_index, right_index) = check_ordering(
            numbers: numbers, entry: entry)
        {
            return .unordered(left_index: left_index, right_index: right_index)
        }
    }
    return .ordered
}

func check_ordering(numbers: [Int], entry: (l: Int, r: Int)) -> order_status {
    guard let left_index: Int = numbers.firstIndex(of: entry.l) else { return .ordered }
    guard let right_index: Int = numbers.firstIndex(of: entry.r) else { return .ordered }
    return (left_index <= right_index)
        ? .ordered : .unordered(left_index: left_index, right_index: right_index)
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
