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
  let index = findBlocker()! - 1
  return String("\(blocks[index].x),\(blocks[index].y)")
}

func findBlocker() -> Int? {
  func findBlocker(start: Int, stepWidth: Int) -> Int? {
    if start >= blocks.count || start <= 0 {
      nil
    } else if findPath(blocks: blocks.prefix(start).toArray(), best: false) == nil {
      stepWidth == 1 ? start : findBlocker(start: start - (stepWidth / 2), stepWidth: stepWidth / 2)
    } else {
      stepWidth == 1 ? nil : findBlocker(start: start + (stepWidth / 2), stepWidth: stepWidth / 2)
    }
  }
  return findBlocker(start: blocks.count - 1, stepWidth: blocks.count)
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

    for dir in [facing, turnLeft(facing), turnRight(facing)] {
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
