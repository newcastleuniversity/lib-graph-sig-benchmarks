#!/bin/bash
# usage: ./benchmark.sh <benchmark_mode> <profiler>
# example: ./benchmark.sh profilers.FlightRecordingProfiler
# shell script to execute jmh benchmarks with a supported profiler 

if [ "$1" = "" ] ; then 
	BENCHMODE="-bm avgt"
else
	BENCHMODE="-bm ${1}"
fi
if [ "$2" = "" ] ; then 
	PROFILER=
else
	PROFILER=-prof=$2
fi

JVMOPTIONS="-server -XX:+UnlockCommercialFeatures -XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints"

# -wi (warmup iterations) -i (iterations) -f (forks) -foe (fail on error) -p (parameters)
BENCHOPTIONS="-wi 10 -i 10 -f 1 -foe true -p l_n=512,1024,2048,3072"

java  $JVMOPTIONS -jar target/benchmarks.jar KeyGenBenchmark $BENCHMODE $PROFILER $BENCHOPTIONS

