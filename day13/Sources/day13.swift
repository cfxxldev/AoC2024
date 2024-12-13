import RegexBuilder

typealias Equation = SIMD3<Int64>
struct Block {
  var x: Equation
  var y: Equation

  init() {
    self.x = Equation.zero
    self.y = Equation.zero
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
  let offset = Equation([0, 0, 10_000_000_000_000])
  return blocks.compactMap { blockOld in
    var block = blockOld
    block.x &+= offset
    block.y &+= offset
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
    case (_, "Button A", let x, let y):
      block.x[0] = x
      block.y[0] = y
    case (_, "Button B", let x, let y):
      block.x[1] = x
      block.y[1] = y
    case (_, "Prize", let x, let y):
      block.x[2] = x
      block.y[2] = y
    default: return
    }
  }
}

func solveBlock(block: Block) -> (buttonA: Int64, buttonB: Int64)? {
  let buttonA =
    (block.x[2] * block.y[1] - block.x[1] * block.y[2])
    / (block.x[0] * block.y[1] - block.x[1] * block.y[0])
  let buttonB = (block.y[2] - buttonA * block.y[0]) / block.y[1]

  guard
    ((block.x[0] * buttonA + block.x[1] * buttonB) == block.x[2])
      && ((block.y[0] * buttonA + block.y[1] * buttonB) == block.y[2])
  else {
    return nil
  }
  return (buttonA: buttonA, buttonB: buttonB)
}
