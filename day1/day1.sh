#/bin/sh

liste1=($(cat input | awk '{print $1}' | sort))
liste2=($(cat input | awk '{print $2}' | sort))

part1() {
    gesamt=0
    for i in "${!liste1[@]}"; do
        diff=$((liste2[i] - liste1[i]))
        diff=${diff/-/}
        gesamt=$((gesamt + diff))
    done
    echo "Part1: $gesamt"
}

part2() {
    gesamt=0
    for n in "${liste1[@]}"; do
        count=$(echo "${liste2[@]}" | tr " " "\n" | grep -c "${n}")
        gesamt=$((gesamt + (n * count)))
    done
    echo "Part2: $gesamt"
}

part1
part2
