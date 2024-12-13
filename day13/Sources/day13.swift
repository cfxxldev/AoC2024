import RegexBuilder

typealias Vector3D = SIMD3<Int64>
struct Block {
  var a: Vector3D
  var b: Vector3D

  init() {
    self.a = Vector3D.zero
    self.b = Vector3D.zero
  }
}

let blocks = fileContent.split(separator: "\n\n").compactMap { s in
  s.split(separator: "\n")
}.compactMap(parseBlock)

func part1() -> Int64 {
  blocks.compactMap(solveBlock).filter { (buttonA, buttonB) in
    buttonA <= 100 && buttonB <= 100
  }.compactMap { (buttonA, buttonB) in
    buttonA * 3 + buttonB
  }.reduce(0, +)
}

func part2() -> Int64 {
  let offset = Vector3D([0, 0, 10_000_000_000_000])
  return blocks.compactMap { blockOld in
    var block = blockOld
    block.a &+= offset
    block.b &+= offset
    return block
  }.compactMap(solveBlock).compactMap { (buttonA, buttonB) in
    buttonA * 3 + buttonB
  }.reduce(0, +)
}

func parseBlock(block: [Substring]) -> Block {
  let regex = Regex {
    Capture {
      ChoiceOf {
        "Button A"
        "Button B"
        "Prize"
      }
    }
    ": "
    ChoiceOf {
      "X+"
      "X="
    }
    TryCapture {
      OneOrMore(.digit)
    } transform: { s in
      Int64(s)
    }
    ", "
    ChoiceOf {
      "Y+"
      "Y="
    }
    TryCapture {
      OneOrMore(.digit)
    } transform: { s in
      Int64(s)
    }
  }

  return block.compactMap { s in
    s.firstMatch(of: regex)
  }.reduce(into: Block()) {
    block, match in
    switch match.output {
    case (_, "Button A", let ax, let bx):
      block.a.x = ax
      block.b.x = bx
    case (_, "Button B", let ay, let by):
      block.a.y = ay
      block.b.y = by
    case (_, "Prize", let az, let bz):
      block.a.z = az
      block.b.z = bz
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
func solveBlock(block: Block) -> (buttonA: Int64, buttonB: Int64)? {
  let cross = crossProduct(block.a, block.b)
  let buttons = cross / (-cross.z)

  guard
    ((dotProduct(block.a, buttons)) == 0)
      && (dotProduct(block.b, buttons) == 0)
  else {
    return nil
  }
  return (buttonA: buttons.x, buttonB: buttons.y)
}
