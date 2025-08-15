set -o xtrace

mkdir -p p0
mkdir -p p1
mkdir -p p2
mkdir -p p3
mkdir -p p4
mkdir -p p5
mkdir -p p6
mkdir -p p7
mkdir -p p8
mkdir -p p9
mkdir -p p10

# num_parties depth gates_per_level compression pking pking_verify filename threads
run_asterisk_benchmark() {
    # Dealer
    ip netns exec neon_ns0 ./asterisk_comparison --num-parties $1 --depth $2 --gates-per-level $3 --net-config net_config.json -o p0/$7.txt --repeat 2 --pid 0 >> p0/log.txt 2>&1 &
    # Parties 2, 3, ..., N
    for i in $( eval echo {2..$1} ); do
        ip netns exec neon_ns$i ./asterisk_comparison --num-parties $1 --depth $2 --gates-per-level $3 --net-config net_config.json -o p$i/$7.txt --repeat 2 --pid $i >> p$i/log.txt 2>&1 &
    done
    # Party 1 where we also display log
    ip netns exec neon_ns1 ./asterisk_comparison --num-parties $1 --depth $2 --gates-per-level $3 --net-config net_config.json -o p1/$7.txt --repeat 2 --pid 1 2>&1 | tee -a p1/log.txt

    sleep 2
}

for i in {1..5}; do
    echo Iteration $i | tee -a iteration_log.txt
    for n in 3 5; do
        # d = 10 ==> per layer = 100000
        run_asterisk_benchmark $n 10 100000 2 true 0 n$n-c2-d10-pking-0 1
        # d = 30 ==> per layer = 33334
        run_asterisk_benchmark $n 30 33334 2 true 0 n$n-c2-d30-pking-0 1
        # d = 100 ==> per layer = 10000
        run_asterisk_benchmark $n 100 10000 2 true 0 n$n-c2-d100-pking-0 1
    done
done

echo DONE
