let decodedContent = fileContent.compactMap(toInt).enumerated().compactMap {
  (index: Int, len: Int) -> [Int?] in
  if index % 2 == 0 {
    Array(repeating: .some(index / 2), count: len)
  } else {
    Array(repeating: .none, count: len)
  }
}.flattened()

func part1() -> Int64 {
  var discContent = decodedContent
  var usedIndices = discContent.indices(where: { $0 != nil }).ranges.flattened()
  var freeIndices = discContent.indices(of: nil).ranges.flattened().reversed().toArray()

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
  var freeRanges = decodedContent.indices(of: nil).ranges.toArray()

  let discContent = (0..<10000).reversed().reduce(
    into: decodedContent
  ) {
    partialResult, fileId in
    for usedRange in partialResult.indices(of: fileId).ranges {
      if case .some(let freeIndex) = freeRanges.firstIndex(where: { rng in
        (rng.count >= usedRange.count) && (rng.startIndex < usedRange.startIndex)
      }), case let freeRange = freeRanges[freeIndex] {
        freeRanges[freeIndex].removeFirst(usedRange.count)
        partialResult.swapAt(freeRange.startIndex, usedRange.startIndex, count: usedRange.count)
      }
    }
  }
  return checksum(discContent)
}

func checksum(_ array: [Int?]) -> Int64 {
  array.enumerated().filter({ _, value in value != nil }).reduce(0) {
    partialResult, element -> Int64 in
    partialResult + Int64(element.offset) * Int64(element.element!)
  }
}
