let decodedContent = fileContent.compactMap(toInt).enumerated().compactMap {
  (index: Int, len: Int) in
  if index % 2 == 0 {
    Array(repeating: index / 2, count: len)
  } else {
    Array(repeating: -1, count: len)
  }
}.flattened()

func part1() -> Int64 {
  var discContent = decodedContent
  var usedIndices: [Int] = discContent.indices { id in id >= 0 }.ranges.flattened()
  var freeIndices: [Int] = discContent.indices { id in id < 0 }.ranges.flattened().reversed()
    .toArray()

  while usedIndices.count > 0 && freeIndices.count > 0 {
    if case .some(let freeIndex) = freeIndices.popLast(),
      case .some(let usedIndex) = usedIndices.popLast(), freeIndex <= usedIndex
    {
      discContent.swapAt(freeIndex, usedIndex)
    }
  }

  return checksum(discContent)
}

func part2() -> Int64 {
  var discContent = decodedContent
  var usedRanges = (0...discContent.max()!).compactMap { i in
    discContent.indices { id in id == i }.ranges
  }.flattened().toArray()

  var freeRanges = discContent.indices { id in id < 0 }.ranges.toArray()

  while usedRanges.count > 0 && freeRanges.count > 0 {
    if case .some(let usedRange) = usedRanges.popLast() {
      if case .some(let freeIndex) = freeRanges.firstIndex(where: { rng in
        (rng.count >= usedRange.count) && (rng[0] < usedRange[0])
      }), case let freeRange = freeRanges[freeIndex] {
        for i in 0..<usedRange.count {
          discContent.swapAt(freeRange[i], usedRange[i])
        }
        freeRanges[freeIndex].removeFirst(usedRange.count)
      }
    }
  }

  return checksum(discContent)
}

func checksum(_ array: [Int]) -> Int64 {
  array.enumerated().filter { _, value in value >= 0 }.reduce(0) {
    partialResult, element -> Int64 in
    partialResult + Int64(element.offset) * Int64(element.element)
  }
}
