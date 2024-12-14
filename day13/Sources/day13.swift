typealias Vector3D = SIMD3<Int64>
struct Block {
  var a: Vector3D
  var b: Vector3D

  init() {
    self.a = Vector3D.zero
    self.b = Vector3D.zero
  }
}

let costs = Vector3D(3, 1, 0)
let blocks = fileContent.split(separator: "\n\n").compactMap { s in
  s.split(separator: "\n")
}.compactMap(parseBlock)

func part1() -> Int64 {
  blocks.compactMap(solveBlock).filter { buttons in
    buttons.x <= 100 && buttons.y <= 100
  }.compactMap { buttons in
    dotProduct(buttons, costs)
  }.reduce(0, +)
}

func part2() -> Int64 {
  let offset = Vector3D([0, 0, 10_000_000_000_000])
  return blocks.compactMap { blockOld in
    var block = blockOld
    block.a &+= offset
    block.b &+= offset
    return block
  }.compactMap(solveBlock)
    .compactMap { buttons in
      dotProduct(buttons, costs)
    }.reduce(0, +)
}

func parseBlock(block: [Substring]) -> Block {
  block.compactMap { s in
    s.firstMatch(
      of: /(Button [AB]|Prize): X.(\d+), Y.(\d+)/
    )
  }.reduce(into: Block()) {
    (block, match) in
    switch match.output {
    case (_, "Button A", let ax, let bx):
      block.a.x = Int64(ax)!
      block.b.x = Int64(bx)!
    case (_, "Button B", let ay, let by):
      block.a.y = Int64(ay)!
      block.b.y = Int64(by)!
    case (_, "Prize", let az, let bz):
      block.a.z = Int64(az)!
      block.b.z = Int64(bz)!
    default: return
    }
  }
}

func shiftProduct(_ a: Vector3D, _ b: Vector3D) -> Vector3D {
  Vector3D(a.y, a.z, a.x) &* Vector3D(b.z, b.x, b.y)
}

func crossProduct(_ a: Vector3D, _ b: Vector3D) -> Vector3D {
  return shiftProduct(a, b) &- shiftProduct(b, a)
}

func dotProduct(_ a: Vector3D, _ b: Vector3D) -> Int64 {
  (a &* b).wrappedSum()
}

func solveBlock(block: Block) -> Vector3D? {
  let cross = crossProduct(block.a, block.b)
  let buttons = cross / (-cross.z)

  guard
    ((dotProduct(block.a, buttons)) == 0)
      && (dotProduct(block.b, buttons) == 0)
  else {
    return nil
  }
  return buttons
}
