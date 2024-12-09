typealias Point = SIMD2<Int>

struct Antenna {
  var type: Character
  var coord: Point
}

let antennas: [Antenna] = splitLines.enumerated().compactMap(row).flattened()

func part1() -> Int {
  antinodes { (point, direction) in
    [point &+ direction]
  }.count
}

func part2() -> Int {
  antinodes { (point, direction) in
    pointsInDirection(
      point: point, direction: direction)
  }.count
}

func antinodes(_ transform: (Point, Point) -> [Point]) -> [Point] {
  antennas.compactMap { currentAntenna in
    antennas.filter { nextAntenna in
      currentAntenna.type == nextAntenna.type && currentAntenna.coord != nextAntenna.coord
    }
    .compactMap { nextAntenna in
      transform(currentAntenna.coord, currentAntenna.coord &- nextAntenna.coord).filter(
        isValidPoint)
    }.flattened()
  }.flattened().uniqued()
}

func row(y: Int, row: Substring) -> [Antenna] {
  row.enumerated().filter { (x, char) in char != "." }.compactMap { (x, char) in
    Antenna(type: char, coord: Point(x: x, y: y))
  }
}

func isValidPoint(_ point: Point) -> Bool {
  point.x >= 0 && point.y >= 0 && point.x < 50 && point.y < 50
}

func pointsInDirection(point: Point, direction: Point) -> [Point] {
  if isValidPoint(point) {
    [point]
      + pointsInDirection(
        point: point &+ direction, direction: direction)
  } else {
    []
  }
}
