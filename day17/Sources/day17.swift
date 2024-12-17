typealias Num = UInt64

enum Operand {
  case literal(_ value: UInt8)
  case a
  case b
  case c
  case error

  init(literal: UInt8) {
    self = .literal(literal)
  }
  init(combo: UInt8) {
    if combo >= 0 && combo <= 3 {
      self = .literal(combo)
    } else if combo == 4 {
      self = .a
    } else if combo == 5 {
      self = .b
    } else if combo == 6 {
      self = .c
    } else {
      self = .error
    }

  }
}

enum Opcode {
  case adv(Operand)
  case bxl(Operand)
  case bst(Operand)
  case jnz(Operand)
  case bxc(Operand)
  case out(Operand)
  case bdv(Operand)
  case cdv(Operand)
}

struct CPU {
  var a: Num = Num.zero
  var b: Num = Num.zero
  var c: Num = Num.zero
  var ip: Int = Int.zero

  var program: [UInt8] = []
  var output: [UInt8] = []
  var execution: [Opcode] = []

  init(_ program: String) {
    for line in program.split(separator: "\n") {
      if line.starts(with: "Register A: ") { self.a = Num(line.dropFirst(12))! }
      if line.starts(with: "Register B: ") { self.b = Num(line.dropFirst(12))! }
      if line.starts(with: "Register C: ") { self.c = Num(line.dropFirst(12))! }
      if line.starts(with: "Program: ") {
        self.program = line.dropFirst(9)
          .split(separator: ",")
          .compactMap(toIntFunc())
      }
    }
  }

  func run() -> Self {
    var newCPU = self
    newCPU.execution.removeAll()
    newCPU.ip = 0
    newCPU.doRun()
    return newCPU
  }

  private mutating func doRun() {
    while let opcode = fetchOp() {
      execution.append(opcode)
      switch opcode {
      case .adv(let operand): self.a = doDiv(decodeOperand(operand))
      case .bdv(let operand): self.b = doDiv(decodeOperand(operand))
      case .cdv(let operand): self.c = doDiv(decodeOperand(operand))
      case .bxl(let operand): self.b = self.b ^ decodeOperand(operand)
      case .bxc(_): self.b = self.b ^ self.c
      case .bst(let operand): self.b = decodeOperand(operand) & 7
      case .out(let operand): self.output.append(UInt8(decodeOperand(operand) & 7))
      case .jnz(let operand): if self.a != 0 { self.ip = Int(decodeOperand(operand)) }
      }
    }
  }

  private mutating func fetchOp() -> Opcode? {
    if ip < 0 || ip >= program.count { return nil }
    let opcode = program[ip]
    let operand = program[ip + 1]
    self.ip += 2
    let ret: Opcode? =
      switch opcode {
      case 0: .adv(.init(combo: operand))
      case 1: .bxl(.init(literal: operand))
      case 2: .bst(.init(combo: operand))
      case 3: .jnz(.init(literal: operand))
      case 4: .bxc(.init(literal: operand))
      case 5: .out(.init(combo: operand))
      case 6: .bdv(.init(combo: operand))
      case 7: .cdv(.init(combo: operand))
      default: nil
      }
    return ret
  }

  private func decodeOperand(_ operand: Operand) -> Num {
    switch operand {
    case .a: self.a
    case .b: self.b
    case .c: self.c
    case .literal(let literal): Num(exactly: literal)!
    case .error: Num.zero
    }
  }

  private func doDiv(_ operand: Num) -> Num {
    self.a >> operand
  }

}

func part1() -> String {
  let cpu = CPU(readFile("input")).run()
  return cpu.output.compactMap { u in String(u) }.joined(separator: ",")
}

func part2() -> UInt64 {
  var cpu = CPU(readFile("input"))
  let input = cpu.program
  var nextA = UInt64(1)
  outer: for j: Num in 1...UInt64(input.count) {
    for i: Num in 0...UInt64.max {
      cpu.a = nextA + i
      let output = cpu.run().output
      if output.count == j {
        if input.suffix(Int(j)) == output {
          nextA = (nextA + i) << 3
          continue outer
        }
      }
    }
  }
  return cpu.a
}
