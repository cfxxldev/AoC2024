typealias Vector2D = SIMD2<Int>
enum MapObject: Character {
  case wall = "#"
  case box = "O"
  case robot = "@"
  case free = "."
  case wideBoxL = "["
  case wideBoxR = "]"
}
typealias Map = [[MapObject]]
enum MovementDirection: Character {
  case left = "<"
  case right = ">"
  case up = "^"
  case down = "v"
}

let directions: [MovementDirection: Vector2D] = [
  .left: Vector2D(-1, 0), .right: Vector2D(1, 0),
  .up: Vector2D(0, -1), .down: Vector2D(0, 1),
]

let fileParts = fileContent.split(separator: "\n\n")
let movements = fileParts[1].compactMap { c in MovementDirection(rawValue: c) }

func part1() -> Int {
  return sumGPS(
    followRobot(
      fileParts[0].split(separator: "\n").compactMap { s in
        s.compactMap { c in MapObject(rawValue: c) }
      }
    ))
}

func part2() -> Int {
  return sumGPS(
    followRobot(
      fileParts[0].split(separator: "\n").compactMap { s in
        s.compactMap { c -> [MapObject] in
          if c == "@" {
            return [.robot, .free]
          } else if c == "O" {
            return [.wideBoxL, .wideBoxR]
          } else {
            return [MapObject(rawValue: c)!, MapObject(rawValue: c)!]
          }
        }.flattened()
      }
    ))
}

func followRobot(_ originalMap: Map) -> Map {
  var map = originalMap
  var robot = findRobot(map)
  for movement in movements {
    if move(&map, position: robot, movement: movement) {
      robot &+= directions[movement]!
    }
  }
  return map
}

func sumGPS(_ map: Map) -> Int {
  map.enumerated().compactMap { y, line in
    line.enumerated().filter { _, o in o == .wideBoxL || o == .box }.compactMap { x, _ in
      Vector2D(x, y)
    }
  }.flattened().reduce(into: Int(0)) { partialResult, pos in
    partialResult += (pos.y * 100) + pos.x
  }
}

func findRobot(_ map: Map) -> Vector2D {
  map.enumerated().compactMap { y, line in
    line.enumerated().filter { _, o in o == .robot }.compactMap { x, _ in
      Vector2D(x, y)
    }
  }.flattened().first!
}

func move(_ map: inout Map, position: Vector2D, newPosition: Vector2D) {
  map[newPosition.y][newPosition.x] = map[position.y][position.x]
  map[position.y][position.x] = .free
}

func move(_ map: inout Map, position: Vector2D, movement: MovementDirection) -> Bool {
  let object = map[position.y][position.x]
  let direction = directions[movement]!
  if object == .free { return true }
  if object == .wall { return false }
  if movement == .up || movement == .down {
    if object == .wideBoxL || object == .wideBoxR {
      let oldState = map
      let positionOther = position &+ directions[object == .wideBoxL ? .right : .left]!
      if move(&map, position: position &+ direction, movement: movement)
        && move(&map, position: positionOther &+ direction, movement: movement)
      {
        move(&map, position: position, newPosition: position &+ direction)
        move(&map, position: positionOther, newPosition: positionOther &+ direction)
        return true
      } else {
        map = oldState
        return false
      }
    }
  }
  if move(&map, position: position &+ direction, movement: movement) {
    move(&map, position: position, newPosition: position &+ direction)
    return true
  }
  return false
}
