#!/usr/bin/env bash

function cleanup()
{
	echo "Cleaning up..."
	ip netns delete babel-fuzzing
}

trap 'cleanup' SIGINT

cleanup
ip netns add babel-fuzzing
ip -n babel-fuzzing link set up dev lo

echo core >/proc/sys/kernel/core_pattern

pushd /sys/devices/system/cpu
echo performance | tee cpu*/cpufreq/scaling_governor
popd

ip netns exec babel-fuzzing ./afl-fuzz -D 50 -t 5000+ -i in -o out -N \
udp://::1:6696 -- ../babeld-althea/babeld -I test.pid -L babeld.log -d 2 lo \
-h 1 -H 1 -C 'hello-interval 1'

cleanup
