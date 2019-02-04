#!/bin/bash
# usage: ./benchmarkProfiling.sh <data path>
# example: ./benchmarkProfiling.sh experiment-fork-20-12-18/
#shell script to create a folder for profiling results in csv files  
YHOME= "/Applications/YourKit-Java-Profiler-2019.1.app/Contents/Resources"

if [ "$1" = "" ] ; then
        DATA_PATH=""
else
	DATA_PATH="${1}"
        cd $DATA_PATH
fi

for filename in *.snapshot; do 
	mkdir "$filename-csv"
	java -jar -Dexport.csv -Dexport.call.tree.cpu -Dexport.method.list.cpu -Dexport.apply.filters "/Applications/YourKit-Java-Profiler-2019.1.app/Contents/Resources/lib/yourkit.jar" -export "$filename" "$filename-csv/"

done 
