#!/bin/bash
mapfile -t liste1 < <( awk '{print $1}' < input | sort)
mapfile -t liste2 < <( awk '{print $2}' < input | sort)

part1() {
    local gesamt=0
    for i in "${!liste1[@]}"; do
        local diff=$((liste2[i] - liste1[i]))
        diff=${diff#-}
        gesamt=$((gesamt + diff))
    done
    echo "Part1: $gesamt"
}

part2() {
    local gesamt=0
    for n in "${liste1[@]}"; do
        local count
        count=$(echo "${liste2[@]}" | tr " " "\n" | grep -c "${n}")
        gesamt=$((gesamt + (n * count)))
    done
    echo "Part2: $gesamt"
}

part1
part2
