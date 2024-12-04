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
enum directions: Int, CaseIterable {

    case UpLeft = 0
    case Left = 1
    case DownLeft = 2
    case Up = 3
    case Down = 4
    case UpRight = 5
    case Right = 6
    case DownRight = 7
}

let direction_values = [
    (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1),
]
let data = read_file().components(separatedBy: "\n").filter({ s in !s.isEmpty }).map { s in
    Array(s)
}
let width = data[0].count
let height = data.count

func get_character(x: Int, y: Int) -> Character {
    if x < 0 || y < 0 || x >= width || y >= height { "_" }
    else {data[y][x]}
}

func read_string_directional(start_x: Int, start_y: Int, direction: directions, len: Int)
    -> String
{
    if len <= 1 {
        String(get_character(x: start_x, y: start_y))
    } else {
        String(get_character(x: start_x, y: start_y))
            + read_string_directional(
                start_x: start_x + direction_values[direction.rawValue].0,
                start_y: start_y + direction_values[direction.rawValue].1, direction: direction,
                len: len - 1)
    }
}

func count_XMAS(start_x: Int, start_y: Int) -> Int {
    directions.allCases.compactMap { direction in
        read_string_directional(
            start_x: start_x, start_y: start_y,
            direction: direction, len: 4)
    }.filter { s in
        s == "XMAS"
    }.count
}

func count_MAS(start_x: Int, start_y: Int) -> Int {
    [
        (directions.UpLeft, directions.DownRight),
        (.UpRight, .DownLeft),
        (.DownLeft, .UpRight),
        (.DownRight, .UpLeft),
    ].compactMap {
        (start_direction, read_direction) in
        read_string_directional(
            start_x: start_x + direction_values[start_direction.rawValue].0,
            start_y: start_y + direction_values[start_direction.rawValue].1,
            direction: read_direction, len: 3)
    }.filter { s in
        s == "MAS"
    }.count
}

print(
    data.enumerated().reduce(0) { summe, row in
        summe
            + row.element.enumerated().filter({ (_, c) in c == "X" }).reduce(0) {
                summe_row, column in
                summe_row + count_XMAS(start_x: column.offset, start_y: row.offset)
            }
    })

print(
    data.enumerated().reduce(0) { summe, row in
        summe
            + row.element.enumerated().filter({ (_, c) in c == "A" }).compactMap { column in
                count_MAS(start_x: column.offset, start_y: row.offset)
            }.filter { anzahl in
                anzahl == 2
            }.count
    })
