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

func part2() -> Num {
  for i: Num in 0... {
    let frame = robots.compactMap { robot in
      positionAfter(robot: robot, seconds: i)
    }.uniqued()
    if frame.count == robots.count {
      drawFrame(
        positions: frame)
      return i
    }
  }
  return 0
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
    repeating: Array(repeating: " ", count: Int(dimensions.x)), count: Int(dimensions.y))
  for pos in positions {
    res[Int(pos.y)][Int(pos.x)] = "*"
  }
  for line in res {
    print(line.reduce(" ", +))
  }
}

func addjustForDimensions(_ position: Vector2D) -> Vector2D {
  ((position % dimensions) &+ dimensions) % dimensions
}

func positionAfter(robot: Robot, seconds: Num) -> Vector2D {
  addjustForDimensions(robot.startPos &+ (robot.velocity &* seconds))
}
