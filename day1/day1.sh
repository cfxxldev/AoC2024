#/bin/sh

liste1=($(cat input | awk '{print $1}' | sort))
liste2=($(cat input | awk '{print $2}' | sort))

part1() {
    gesamt=0
    for i in "${!liste1[@]}"; do
        diff=$(awk "BEGIN {x=${liste1[$i]}; y=${liste2[$i]}; print y-x;}")
        diff=${diff/-/}
        gesamt=$(awk "BEGIN {x=${gesamt}; y=${diff}; print x+y;}")
    done
    echo "Part1: $gesamt"
}

part2() {
    gesamt=0
    for n in "${liste1[@]}"; do
        count=$(echo "${liste2[@]}" | tr " " "\n" | grep -c "${n}")
        gesamt=$(awk "BEGIN {x=${gesamt}; y=(${n} * ${count}); print x+y;}")
    done
    echo "Part2: $gesamt"
}

part1
part2
