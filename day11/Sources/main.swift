import Foundation

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
