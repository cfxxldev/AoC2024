import Foundation

func read_file() -> String {
    do {
        let dir = URL(filePath: FileManager.default.currentDirectoryPath)
        let inputUrl = dir.appendingPathComponent("input")

        return try String(contentsOf: inputUrl, encoding: .ascii)
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
    do {
        let content = read_file()
        let regex: Regex<(Substring, Substring?, Substring?, Substring?, Substring?, Substring?)> =
            try Regex("(do)\\(\\)|(don't)\\(\\)|(mul)\\((\\d{1,3}),(\\d{1,3})\\)")

        var mul = true
        let summe = content.matches(of: regex).compactMap { m in
            (m.output.1 ?? m.output.2 ?? m.output.3).map { o in
                switch o {
                case "do":
                    mul = true
                    return 0
                case "don't":
                    mul = false
                    return 0
                case "mul":
                    if mul {
                        let x = Int(m.output.4 ?? "0")!
                        let y = Int(m.output.5 ?? "0")!
                        return (x) * (y)
                    }
                    return 0
                default:
                    return 0
                }
            }
        }.reduce(0) { partialResult, value in
            partialResult + value
        }

        print(summe)
    } catch {
        print(error)

    }
}

part1()
part2()
