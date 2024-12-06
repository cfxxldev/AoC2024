import Foundation
import RegexBuilder

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

func part1() -> Int {
  let content = read_file()
  let regex = /(mul)\((\d{1,3}),(\d{1,3})\)/

  return content.matches(of: regex).compactMap { m in
    ((Int(m.output.2) ?? 0) * (Int(m.output.3) ?? 0))
  }.reduce(0, +)
}

enum Operation: Comparable {
  case doIt
  case dont
  case mul(x: Int, y: Int)
}

func part2() -> Int {
  let content = read_file()

  let regDo = /do\(\)/
  let regDont = /don't\(\)/
  let regMul = /mul\(\d{1,3},\d{1,3}\)/
  let regMul_Capture = /mul\((\d{1,3}),(\d{1,3})\)/

  let regex = Regex {
    TryCapture {
      ChoiceOf {
        regDo
        regDont
        regMul
      }
    } transform: { (t) -> Operation in
      if let d = t.wholeMatch(of: regMul_Capture) {
        return .mul(x: Int(d.output.1) ?? 0, y: Int(d.output.2) ?? 0)
      } else if t.wholeMatch(of: regDont) != nil {
        return .dont
      } else {
        return .doIt
      }
    }
  }
  var mul = 1
  return content.matches(of: regex).compactMap { m in
    switch m.output.1 {
    case .doIt:
      mul = 1
      return 0
    case .dont:
      mul = 0
      return 0
    case let .mul(param1, param2):
      return mul * param1 * param2
    }
  }.reduce(0, +)
}

print("part1: \(part1())")
print("part2: \(part2())")
