import Foundation

let fileContent = readFile("input")
let splitLines = fileContent.split(separator: "\n")

func readFile(_ file: String) -> String {
  do {
    return try String(
      contentsOf: URL(filePath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(file), encoding: .ascii)
  } catch {
    print(error)
    exit(1)
  }
}

var main = Main()
print("part1: \(main.part1())")
print("part2: \(main.part2())")
