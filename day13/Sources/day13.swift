typealias Equation = SIMD3<Int64>
struct Block {
  var e1: Equation
  var e2: Equation

  init() {
    self.e1 = Equation.zero
    self.e2 = Equation.zero
  }
}

let blocks = fileContent.split(separator: "\n\n").compactMap { s in
  s.split(separator: "\n")
}

func part1() -> Int64 {
  blocks.compactMap(parseBlock).compactMap(solveBlock).filter { (buttonA, buttonB) in
    buttonA <= 100 && buttonB <= 100
  }.compactMap { (buttonA, buttonB) in
    buttonA * 3 + buttonB
  }.flattened()
}
func part2() -> Int64 {
  let offset = Equation([0, 0, 10_000_000_000_000])
  return blocks.compactMap(parseBlock).compactMap { blockOld in
    var block = blockOld
    block.e1 &+= offset
    block.e2 &+= offset
    return block
  }.compactMap(solveBlock).compactMap { (buttonA, buttonB) in
    buttonA * 3 + buttonB
  }.flattened()
}

func parseBlock(block: [Substring]) -> Block {
  let regex_A = /Button (A): X\+(\d+), Y\+(\d+)/
  let regex_B = /Button (B): X\+(\d+), Y\+(\d+)/
  let regex_Prize = /(P)rize: X\=(\d+), Y\=(\d+)/

  return block.compactMap { s in
    s.firstMatch(of: regex_A) ?? s.firstMatch(of: regex_B) ?? s.firstMatch(of: regex_Prize)
  }.reduce(into: Block()) {
    block, match in
    switch match.output {
    case (_, "A", let x, let y):
      block.e1[0] = Int64(x)!
      block.e2[0] = Int64(y)!
    case (_, "B", let x, let y):
      block.e1[1] = Int64(x)!
      block.e2[1] = Int64(y)!
    case (_, "P", let x, let y):
      block.e1[2] = Int64(x)!
      block.e2[2] = Int64(y)!
    default: return
    }
  }
}

func solveBlock(block: Block) -> (buttonA: Int64, buttonB: Int64)? {
  let buttonA =
    (block.e1[2] * block.e2[1] - block.e1[1] * block.e2[2])
    / (block.e1[0] * block.e2[1] - block.e1[1] * block.e2[0])
  let buttonB = (block.e2[2] - buttonA * block.e2[0]) / block.e2[1]

  guard
    ((block.e1[0] * buttonA + block.e1[1] * buttonB) == block.e1[2])
      && ((block.e2[0] * buttonA + block.e2[1] * buttonB) == block.e2[2])
  else {
    return nil
  }
  return (buttonA: buttonA, buttonB: buttonB)
}
