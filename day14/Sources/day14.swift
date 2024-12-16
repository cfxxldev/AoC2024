typealias Num = Int64
typealias Vector2D = SIMD2<Num>
struct Robot {
  let startPos: Vector2D
  let velocity: Vector2D
}

let robots = fileContent.split(separator: "\n").compactMap(parseRobot)
let dimensions = Vector2D(101, 103)

func part1() -> Num {
  let middle = dimensions / 2
  let result = robots.compactMap { robot in
    positionAfter(robot: robot, seconds: 100)
  }.compactMap { pos in
    SIMD4<Num>(
      (pos.x < middle.x && pos.y < middle.y) ? 1 : 0,
      (pos.x < middle.x && pos.y > middle.y) ? 1 : 0,
      (pos.x > middle.x && pos.y < middle.y) ? 1 : 0,
      (pos.x > middle.x && pos.y > middle.y) ? 1 : 0)
  }.reduce(SIMD4<Num>.zero) { result, counts in
    result &+ counts
  }

  return result[0] * result[1] * result[2] * result[3]
}

func part2() -> String {
  for seconds: Num in 0..<(dimensions.x * dimensions.y) {
    let frame = robots.compactMap { robot in
      positionAfter(robot: robot, seconds: seconds)
    }.uniqued().sorted { a, b in a.y < b.y }
    if maybeTree(positions: frame) {
      drawFrame(
        positions: frame)
      print("possible Tree after \(seconds) seconds")
    }
  }
  return "Hopefully there was a tree"
}

func parseRobot(_ line: Substring) -> Robot? {
  line.firstMatch(
    of: /p=(?<px>\d+),(?<py>\d+) v=(?<vx>-{0,1}\d+),(?<vy>-{0,1}\d+)/
  ).flatMap { match -> Robot? in
    if case (.some(let px), .some(let py), .some(let vx), .some(let vy)) = (
      Num(match.output.px), Num(match.output.py), Num(match.output.vx), Num(match.output.vy)
    ) {
      Robot(startPos: [px, py], velocity: [vx, vy])
    } else {
      nil
    }
  }
}

func drawFrame(positions: [Vector2D]) {
  var res = Array(
    repeating: Array(repeating: ".", count: Int(dimensions.x)), count: Int(dimensions.y))
  for pos in positions {
    res[Int(pos.y)][Int(pos.x)] = "*"
  }
  for line in res {
    print(line.reduce("", +))
  }
}

func maybeTree(positions: [Vector2D]) -> Bool {
  struct Consts {
    static let l = Vector2D(-1, 1)
    static let r = Vector2D(1, 1)
  }
  outerloop: for (index, pos) in positions.enumerated() {
    for i: Num in 1...3 {
      guard positions.dropFirst(index).contains(pos &+ (Consts.l &* i)) else { continue outerloop }
      guard positions.dropFirst(index).contains(pos &+ (Consts.r &* i)) else { continue outerloop }
    }
    return true
  }
  return false
}

func addjustForDimensions(_ position: Vector2D) -> Vector2D {
  ((position % dimensions) &+ dimensions) % dimensions
}

func positionAfter(robot: Robot, seconds: Num) -> Vector2D {
  addjustForDimensions(robot.startPos &+ (robot.velocity &* seconds))
}
