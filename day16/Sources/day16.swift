typealias Num = Int64
typealias Vector2D = SIMD2<Int>
enum Direction {
  case west, north, east, south
}
let movements: [Direction: Vector2D] = [
  .west: [-1, 0], .north: [0, -1], .east: [1, 0], .south: [0, 1],
]
enum FloorTile: Equatable {
  case wall
  case start
  case end
  case floor(maxCost: Num = Num.max)
}

let floorMap = fileContent.split(separator: "\n").compactMap { line in
  line.compactMap { c -> FloorTile in
    switch c {
    case "#": .wall
    case "S": .start
    case "E": .end
    default: .floor()
    }
  }
}

let startPosition: Vector2D = floorMap.enumerated().filter { line in
  line.element.contains(.start)
}.reduce(into: .zero) { (result, line) in
  result = [line.element.firstIndex(of: .start)!, line.offset]
}

let bestPaths = findBestPaths()

func part1() -> Num {
  return bestPaths.maxCost
}

func part2() -> Int {
  return bestPaths.countBestTiles
}

func printPath(_ path: [Direction]) {
  print(
    path.compactMap { d in
      switch d {
      case .east: "E"
      case .north: "N"
      case .west: "W"
      case .south: "S"
      }
    }.reduce("", +))
}

func turnRight(_ direction: Direction) -> Direction {
  switch direction {
  case .north: .east
  case .east: .south
  case .south: .west
  case .west: .north
  }
}

func turnLeft(_ direction: Direction) -> Direction {
  switch direction {
  case .north: .west
  case .west: .south
  case .south: .east
  case .east: .north
  }
}

func findBestPaths() -> (maxCost: Num, countBestTiles: Int) {
  var bestPaths: [[Vector2D]] = []
  var maxCost = Num.max
  var map = floorMap

  func move(from: Direction, position: Vector2D, path: [Vector2D], cost: Num) {
    if map[position.y][position.x] == .end {
      if cost < maxCost {
        maxCost = cost
        bestPaths.removeAll()
      }
      if cost == maxCost {
        bestPaths.append(path + [position])
      }
      return
    }
    if map[position.y][position.x] == .wall { return }
    if case .floor(let floorCost) = map[position.y][position.x] {
      if cost > floorCost { return }
      map[position.y][position.x] = .floor(maxCost: min(floorCost, cost))
    }
    if cost > maxCost { return }
    for dir in [turnLeft(from), turnRight(from), from] {
      let newCost = cost + ((dir == from) ? 1 : 1001)
      move(
        from: dir, position: position &+ movements[dir]!, path: path + [position],
        cost: newCost)
    }
  }
  move(from: .east, position: startPosition, path: [], cost: 0)

  return (maxCost: maxCost, countBestTiles: bestPaths.flattened().uniqued().toArray().count)
}
