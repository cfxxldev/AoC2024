import CoreFoundation

enum TransformedNumber {
  case number(number: Int64, count: Int)
  case pair(left: Int64, right: Int64, count: Int)
}

let initialNumbers: [Int64: Int] = fileContent.filter { $0 != "\n" }.split(separator: " ")
  .compactMap(
    toIntFunc(Int64.self)
  ).reduce(into: [:]) { ret, value in
    ret[value] = (ret[value] ?? 0) + 1
  }

func part1() -> Int {
  countStonesAfter(blinks: 25)
}

func part2() -> Int {
  countStonesAfter(blinks: 75)
}

func countStonesAfter(blinks: Int) -> Int {
  blink(initialNumbers, blinks).reduce(0) { partialResult, value in
    partialResult + value.value
  }
}

func blink(_ countedNumbers: [Int64: Int], _ count: Int) -> [Int64: Int] {
  if count <= 0 { return countedNumbers }
  return blink(
    countNumbers(
      countedNumbers
        .compactMap { (key: Int64, value: Int) in
          transformNumber(number: key, count: value)
        }), count - 1)
}

func transformNumber(number: Int64, count: Int) -> TransformedNumber {
  if number == 0 {
    return .number(number: 1, count: count)
  } else if case let digits = numDigits(number), digits % 2 == 0 {
    let div = Int64(pow(10, Double(digits / 2)))
    return .pair(left: number / div, right: number % div, count: count)
  } else {
    return .number(number: number * 2024, count: count)
  }
}

func numDigits(_ number: Int64) -> Int {
  Int(log10(Double(number))) + 1
}

func countNumbers(_ numbers: [TransformedNumber]) -> [Int64: Int] {
  numbers.reduce(into: [:]) { ret, value in
    switch value {
    case .number(let number, let count): ret[number] = (ret[number] ?? 0) + count
    case .pair(let left, let right, let count):
      ret[left] = (ret[left] ?? 0) + count
      ret[right] = (ret[right] ?? 0) + count
    }

  }
}
