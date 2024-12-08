struct Point: Comparable, Hashable {
  var x: Int
  var y: Int

  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.x < rhs.x || ((lhs.x == rhs.x) && (lhs.y < rhs.y))
  }
  static func - (lhs: Self, rhs: Self) -> Self {
    Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }
  static func + (lhs: Self, rhs: Self) -> Self {
    Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }
}

struct Antenna {
  var typ: Character
  var coord: Point
}

let antennas = readFile().split(separator: "\n").enumerated().compactMap { (y, row) in
  row.enumerated().filter { (x, char) in char != "." }.compactMap { (x, char) in
    Antenna(typ: char, coord: Point(x: x, y: y))
  }
}.reduce([], +)

func part1() -> Int {
  antennas.compactMap { currentAntenna in
    antennas.filter { nextAntenna in
      currentAntenna.typ == nextAntenna.typ && currentAntenna.coord != nextAntenna.coord
    }
    .compactMap { nextAntenna in
      pointInDirection(
        point: currentAntenna.coord, direction: currentAntenna.coord - nextAntenna.coord)
    }.filter(isValidPoint)
  }.reduce([], +).uniqued().count
}

func part2() -> Int {
  antennas.compactMap { currentAntenna in
    antennas.filter { nextAntenna in
      currentAntenna.typ == nextAntenna.typ && currentAntenna.coord != nextAntenna.coord
    }
    .compactMap { nextAntenna in
      pointsInDirection(
        point: currentAntenna.coord, direction: currentAntenna.coord - nextAntenna.coord)
    }.reduce([], +)
  }.reduce([], +).uniqued().count
}

func isValidPoint(_ point: Point) -> Bool {
  point.x >= 0 && point.y >= 0 && point.x < 50 && point.y < 50
}

func pointInDirection(point: Point, direction: Point) -> Point {
  point + direction
}

func pointsInDirection(point: Point, direction: Point) -> [Point] {
  if isValidPoint(point) {
    [point]
      + pointsInDirection(
        point: pointInDirection(point: point, direction: direction), direction: direction)
  } else {
    []
  }
}
