typealias Num = Int

let width: Num = 71
let height: Num = 71

let startPosition = Vector2D(0, 0)
let endPosition = Vector2D(width - 1, height - 1)

let blocks = fileContent.split(separator: "\n").compactMap { line in
  line.firstMatch(of: /(?<x>\d+),(?<y>\d+)/).flatMap { match in
    if case (.some(let x), .some(let y)) = (Num(match.output.x), Num(match.output.y)) {
      return Vector2D([x, y])
    } else {
      return nil
    }
  }
}

func part1() -> Num {
  return findPath(blocks: blocks.prefix(1024).toArray(), best: true)!
}

func part2() -> String {
  let index = blocks.fastFirstIndex { index in
    findPath(blocks: blocks.prefix(index + 1).toArray(), best: false) == nil
  }!
  return String("\(blocks[index].x),\(blocks[index].y)")
}

func findPath(blocks: [Vector2D], best: Bool) -> Num? {
  var maxCost: Num?

  var tileCosts = (0..<height).compactMap { y in
    (0..<width).compactMap { x in
      if blocks.contains([x, y]) { -1 } else { Num.max }
    }
  }
  func move(facing: Direction, position: Vector2D, cost: Num) -> Bool {
    if position.x < 0 || position.y < 0 || position.x >= width || position.y >= height {
      return false
    }
    if position == endPosition {
      if cost < (maxCost ?? Num.max) {
        maxCost = cost
      }
      return true
    }
    if cost >= (maxCost ?? Num.max) { return false }

    let tileCost = tileCosts[Int(position.y)][Int(position.x)]
    if cost >= tileCost { return false }
    tileCosts[Int(position.y)][Int(position.x)] = cost

    for dir in [facing, turnLeft(facing), turnRight(facing)].sorted(by: { dir1, dir2 in
      let p1 = position &+ movements[dir1]!
      let p2 = position &+ movements[dir2]!
      return distance(p1, endPosition) < distance(p2, endPosition)
    }) {
      let newCost = cost + 1
      if move(
        facing: dir,
        position: position &+ movements[dir]!,
        cost: newCost) && !best
      {
        return true
      }
    }
    return false
  }
  _ = move(facing: .east, position: startPosition, cost: 0)
  return maxCost
}
