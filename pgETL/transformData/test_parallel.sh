#!/bin/bash

parallelization_function() {
    echo $number
}

max_num_processes=100
limited_factor=4
num_processes=$((max_num_processes/limited_factor))

vals=$(seq 0 1 200)
echo $vals

for number in $vals;
do
    ((i=i%num_processes)); ((i++==0)) && wait
    parallelization_function &
done