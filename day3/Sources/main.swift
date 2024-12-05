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

func part1() {
    let content = read_file()
    let regex = /(mul)\((\d{1,3}),(\d{1,3})\)/

    let summe = content.matches(of: regex).reduce(0) { partialResult, m in
        partialResult + ((Int(m.output.2) ?? 0) * (Int(m.output.3) ?? 0))
    }
    print(summe)
}

func part2() {
    let content = read_file()
    let regex: Regex<(Substring, Substring, Substring?, Substring?)> =
        /(?:(do|don't|mul))\((?:(?:)|(\d+)\,(\d+))\)/

    var mul = 1
    let summe = content.matches(of: regex).compactMap { m in
        switch m.output {
        case (_, "do", nil, nil):
            mul = 1
            return 0
        case (_, "don't", nil, nil):
            mul = 0
            return 0
        case (_, "mul", .some(let param1), .some(let param2)):
            return [param1, param2].compactMap { Int($0) }.reduce(mul) {
                sum, value in sum * value
            }
        default:
            return 0
        }
    }.reduce(0) { partialResult, value in
        partialResult + value
    }

    print(summe)
}

part1()
part2()
