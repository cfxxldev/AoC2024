import Foundation

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

    return content.matches(of: regex).reduce(0) { partialResult, m in
        partialResult + ((Int(m.output.2) ?? 0) * (Int(m.output.3) ?? 0))
    }
}

func part2() -> Int {
    let content = read_file()
    let regex: Regex<(Substring, Substring, Substring?, Substring?)> =
        /(?:(do|don't|mul))\((?:(?:)|(\d+)\,(\d+))\)/

    var mul = 1
    return content.matches(of: regex).compactMap { m in
        switch m.output {
        case (_, "do", nil, nil):
            mul = 1
            return 0
        case (_, "don't", nil, nil):
            mul = 0
            return 0
        case (_, "mul", .some(let param1), .some(let param2)):
            if case (.some(let p1), .some(let p2)) = (Int(param1), Int(param2)) {
                return mul * p1 * p2
            }
            return 0
        default:
            return 0
        }
    }.reduce(0) { partialResult, value in
        partialResult + value
    }
}

print("part1: \(part1())")
print("part2: \(part2())")
