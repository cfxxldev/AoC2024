class Main {
  static let distanceMap = computeDistanceMap()
  static let width = distanceMap[0].count
  static let height = distanceMap.count

  func part1() -> Int {
    return Self.countCheats(2)
  }

  func part2() -> Int {
    return Self.countCheats(20)
  }

  static func isValid(_ position: Vector2D) -> Bool {
    (position.x >= 0 && position.y >= 0 && position.x < width && position.y < height)
  }

  static func distance(_ position: Vector2D) -> Int? {
    (isValid(position) && (distanceMap[position.y][position.x] >= 0))
      ? distanceMap[position.y][position.x] : nil
  }

  static func countCheats(at: Vector2D, _ radius: Int) -> Int {
    let dist = distance(at)!
    return (2...radius).compactMap { r in
      (0...r).compactMap { dx -> [Vector2D] in
        let dy = r - dx
        return [
          [at.x + dx, at.y + dy], [at.x + dx, at.y - dy],
          [at.x - dx, at.y + dy], [at.x - dx, at.y - dy],
        ]
      }.flattened().uniqued().compactMap(distance).filter { d in
        (d - dist) >= (100 + r)
      }
    }.flattened().count
  }

  static func countCheats(_ radius: Int) -> Int {
    let distances = distanceMap.enumerated().compactMap { (y, line) in
      line.enumerated().filter({ _, dist in dist >= 0 }).compactMap { (x, _) in
        countCheats(at: [x, y], radius)
      }.reduce(0, +)
    }.reduce(0, +)
    return distances
  }

  static func computeDistanceMap() -> [[Int]] {
    var _startPosition = Vector2D.zero
    var _endPosition = Vector2D.zero
    var _distanceMap = fileContent.split(separator: "\n").enumerated().compactMap { y, line in
      line.enumerated().compactMap { x, c -> Int in
        if c == "S" {
          _startPosition = Vector2D(x, y)
          return 0
        } else if c == "E" {
          _endPosition = Vector2D(x, y)
        }
        return if c == "#" { -1 } else { Int.max }
      }
    }

    var _position = _startPosition
    var _distance = Int.zero
    while _position != _endPosition {
      for (_, movement) in movements {
        if _distanceMap[_position.y + movement.y][_position.x + movement.x] >= _distance + 1 {
          _distanceMap[_position.y + movement.y][_position.x + movement.x] = _distance + 1
          _position &+= movement
          _distance += 1
          break
        }
      }
    }
    return _distanceMap
  }
}
