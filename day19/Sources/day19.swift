class Main {
  static let fileParts = fileContent.split(separator: "\n\n")
  let towels = fileParts[0].split(separator: ",").compactMap { s in
    s.filter({ c in c != " " })
  }.sorted { s1, s2 in
    let b1 = s1.first!
    let b2 = s2.first!
    return b1 < b2 || (b1 == b2 && s1.count > s2.count)
  }
  let designs = fileParts[1].split(separator: "\n").compactMap(String.init)

  var cache: [String: Num] = [:]

  func part1() -> Int {
    return designs.filter(checkDesign).count
  }

  func part2() -> Num {
    return designs.compactMap(countDesigns).reduce(Num.zero, +)
  }

  func checkDesign(_ design: String) -> Bool {
    countDesigns(design) > 0
  }

  func countDesigns(_ design: String) -> Num {
    if design.count == 0 { return 1 }
    if cache[design] != nil { return cache[design]! }
    let candidates = towels.filter { s in s.first! == design.first! }
    var count = Num.zero
    for towel in candidates {
      if design.starts(with: towel) {
        let newDesign = String(design.dropFirst(towel.count))
        count += countDesigns(newDesign)
      }
    }
    cache[design] = count
    return count
  }
}
