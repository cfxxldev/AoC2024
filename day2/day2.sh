#!/bin/bash

check_line() {
    read -ra line < <(echo "$1")
    local lastsign=-1
    for i in "${!line[@]}"; do
        local pair=("${line[@]:$i:2}")

        if [ "${#pair[@]}" -eq "2" ]; then
            local diff=$((pair[1] - pair[0]))
            local sign=$((diff < 0))

            if [ "$lastsign" -ge "0" ] && [ "$sign" -ne "$lastsign" ]; then
                echo "$i"
                return
            fi
            lastsign=$sign
            diff=${diff#-}
            if [ "$diff" -lt "1" ] || [ "$diff" -gt "3" ]; then
                echo "$i"
                return
            fi
        fi
    done
    echo "-1"
    return
}

retry() {
    local line
    read -ra line < <(echo "$1")
    for remove_index in "${!line[@]}"; do
        local test_line=("${line[@]:0:remove_index}" "${line[@]:((remove_index + 1))}")

        local err_index
        err_index=$(check_line "${test_line[*]}")
        if [ "$err_index" -lt "0" ]; then
            echo "1"
            return
        fi
    done
    echo "0"
    return
}

both_parts() {
    local count_part1=0
    local count_part2=0
    while read -r p; do
        local err_index
        err_index=$(check_line "${p}")
        if [ "$err_index" -lt "0" ]; then
            count_part1=$((count_part1 + 1))
            count_part2=$((count_part2 + 1))
        elif [ "$(retry "${p}")" -ne "0" ]; then
            count_part2=$((count_part2 + 1))
        fi
    done <input
    echo "Part1: ${count_part1}"
    echo "Part2: ${count_part2}"
}

both_parts
