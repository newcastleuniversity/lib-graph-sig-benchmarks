#!/bin/bash
# usage: ./benchmarkProfiling.sh <data path>
# example: ./benchmarkProfiling.sh experiment-fork-20-12-18/
# shell script to export the call tree and method list in csv files  
YHOME='/Applications/YourKit-Java-Profiler-2019.8.app/Contents/Resources'
echo "$YHOME/lib/yourkit.jar"

if [ "$1" = "" ] ; then
        DATA_PATH=""
else
	DATA_PATH="${1}"
        cd $DATA_PATH
fi

for filename in *.snapshot; do 
	mkdir "$filename-csv"
	java -Djava.awt.headless=true -jar -Dexport.csv -Dexport.call.tree.cpu -Dexport.method.list.cpu -Dexport.apply.filters "$YHOME/lib/yourkit.jar" -export "$filename" "$filename-csv/"
done 

