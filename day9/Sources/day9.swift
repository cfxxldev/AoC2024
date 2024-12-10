struct DiscData {
  let decodedContent: [Int?]
  let usedRanges: [Range<Int>]
  let freeRanges: [Range<Int>]

  init(fileContent: String) {
    var currentIndex: Array.Index = 0
    var usedRanges: [Range<Int>] = []
    var freeRanges: [Range<Int>] = []
    self.decodedContent = fileContent.compactMap(toInt).enumerated().compactMap {
      (index: Int, len: Int) -> [Int?] in
      if index % 2 == 0 {
        usedRanges.append(
          Range<Int>(uncheckedBounds: (lower: currentIndex, upper: currentIndex + len)))
        currentIndex += len
        return Array(repeating: .some(index / 2), count: len)
      } else {
        freeRanges.append(
          Range<Int>(uncheckedBounds: (lower: currentIndex, upper: currentIndex + len)))
        currentIndex += len
        return Array(repeating: .none, count: len)
      }
    }.flattened()
    self.usedRanges = usedRanges
    self.freeRanges = freeRanges
  }
}

let discData = DiscData(fileContent: fileContent)

func part1() -> Int64 {
  var discContent = discData.decodedContent
  var usedIndices = discData.usedRanges.flattened().toArray()
  var freeIndices = discData.freeRanges.flattened().reversed().toArray()

  while usedIndices.count > 0 && freeIndices.count > 0 {
    guard case .some(let freeIndex) = freeIndices.popLast(),
      case .some(let usedIndex) = usedIndices.popLast(),
      freeIndex <= usedIndex
    else {
      break
    }
    discContent.swapAt(freeIndex, usedIndex)
  }

  return checksum(discContent)
}

func part2() -> Int64 {
  var discContent = discData.decodedContent
  var freeRanges = discData.freeRanges

  for usedRange in discData.usedRanges.reversed() {
    if case .some(let freeIndex) = freeRanges.firstIndex(where: { rng in
      (rng.count >= usedRange.count) && (rng.startIndex < usedRange.startIndex)
    }),
      case let freeRange = freeRanges[freeIndex]
    {
      freeRanges[freeIndex].removeFirst(usedRange.count)
      discContent.swapAt(freeRange.startIndex, usedRange.startIndex, count: usedRange.count)
    }
  }

  return checksum(discContent)
}

func checksum(_ seq: [Int?]) -> Int64 {
  seq.enumerated().filter({ _, value in value != nil }).reduce(0) {
    partialResult, element -> Int64 in
    partialResult + Int64(element.offset) * Int64(element.element!)
  }
}
