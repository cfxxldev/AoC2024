#!/bin/sh

check_line() {
        line=($1)
        lastsign=-1
        for i in "${!line[@]}"; do
            pair=(${line[@]: $i:2})

            if [ "${#pair[@]}" -eq "2" ]; then
                diff=$((pair[1] - pair[0]))
                sign=$((diff<0))

                if [ "$lastsign" -ge "0" ]; then
                    if [ "$sign" -ne "$lastsign" ]; then
                        echo "$i"
                        return
                    fi
                fi
                lastsign=$sign
                diff=${diff/-/}
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
    param1=${1}
    line=(${param1})
    for remove_index in ${!line[@]}; do
        test_line=(${param1})
        unset test_line[$remove_index]

        err_index=$(check_line "$(echo ${test_line[@]})")
        if [ "$err_index" -lt "0" ]; then
            echo "1"
            return
        fi
    done
    echo "0"
    return
}

both_parts() {
    count_part1=0
    count_part2=0
    while read p; do
        err_index=$(check_line "${p}")
        if [ "$err_index" -lt "0" ]; then
            count_part1=$((count_part1+1))
            count_part2=$((count_part2+1))
        else
            if [ "$(retry "${p}")" -ne "0" ]; then
                count_part2=$((count_part2+1))
            fi
        fi
    done <input
    echo "Part1: ${count_part1}"
    echo "Part2: ${count_part2}"
}

both_parts
