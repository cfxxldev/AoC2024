typealias Num = Int64
typealias Vector2D = SIMD2<Int>
enum Direction {
  case west, north, east, south
}
let movements: [Direction: Vector2D] = [
  .west: [-1, 0], .north: [0, -1], .east: [1, 0], .south: [0, 1],
]
enum Orientation {
  case ns, we
}
enum Tile: Character {
  case wall = "#"
  case start = "S"
  case end = "E"
  case floor = "."
}

let floorMap = fileContent.split(separator: "\n").compactMap { line in
  line.compactMap { c in Tile(rawValue: c) }
}

let width = floorMap[0].count
let height = floorMap.count

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

struct PathNode: Equatable, Hashable {
  let orientation: Orientation
  let pos: Vector2D

  init(_ facing: Direction, _ position: Vector2D) {
    self.pos = position
    orientation = (facing == .north || facing == .south) ? .ns : .we
  }
}

func findBestPaths() -> (maxCost: Num, countBestTiles: Int) {
  var bestPaths: [[Vector2D]] = []
  var maxCost = Num.max

  var cache: [PathNode: Num] = [:]

  func move(facing: Direction, position: Vector2D, path: [Vector2D], cost: Num) {
    if floorMap[position.y][position.x] == .end {
      if cost < maxCost {
        maxCost = cost
        bestPaths.removeAll()
      }
      if cost == maxCost {
        bestPaths.append(path + [position])
      }
      return
    }
    if floorMap[position.y][position.x] == .wall { return }
    if cost > maxCost { return }

    if path.firstIndex(where: { a in a == position }) != nil { return }

    let pathNode = PathNode(facing, position)
    let tileCost = cache[pathNode, default: Num.max]
    if cost > tileCost { return }
    cache[pathNode, default: Num.max] = min(tileCost, cost)

    for dir in [facing, turnLeft(facing), turnRight(facing)] {
      let newCost = cost + ((dir == facing) ? 1 : 1001)
      move(
        facing: dir,
        position: position &+ movements[dir]!,
        path: path + [position],
        cost: newCost)
    }
  }
  move(facing: .east, position: startPosition, path: [], cost: 0)

  return (maxCost: maxCost, countBestTiles: bestPaths.flattened().uniqued().toArray().count)
}
