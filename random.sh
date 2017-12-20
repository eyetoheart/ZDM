#!/bin/bash

rand () {

min=$1
max=$(($2-$min+1))
num=$(($RANDOM+1000000000))
echo $(($num%$max+$min))

}

for i in `seq 1 200`
do
    rnd=$(rand  1  10)
    echo "$i:$rnd"
done
