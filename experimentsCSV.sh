#!/bin/bash
# usage: ./benchmarkProfiling.sh <benchmark_mode> <profiler>
# example: ./benchmarkProfiling.sh avgt profilers.FlightRecordingProfiler
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

JVMOPTIONS=" -XX:+UnlockCommercialFeatures -XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints"

FLIGHTRECOPTIONS=" -XX:+UnlockCommercialFeatures -XX:+FlightRecorder -XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints -XX:StartFlightRecording=settings=profiling.jfc,defaultrecording=true -XX:FlightRecorderOptions=dumponexit=true,stackdepth=512,dumponexitpath=data/"

# -wi (warmup iterations) -i (iterations) -f (forks) -foe (fail on error) -p (parameters)
BENCHOPTIONS=" -wi 1 -i 1 -f 1 -foe true -p l_n=512,1024,2048,3072"

java  $FLIGHTRECOPTIONS -jar target/benchmarks.jar KeyGenBenchmark $BENCHMODE $PROFILER $BENCHOPTIONS

