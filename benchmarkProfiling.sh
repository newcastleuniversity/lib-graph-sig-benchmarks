#!/bin/bash
# usage: ./benchmarkProfiling.sh <data path>
# example: ./benchmarkProfiling.sh experiment-fork-20-12-18/
#shell script to create an csv file from performance experiments 

if [ "$1" = "" ] ; then
        DATA_PATH=""
else
	DATA_PATH="${1}"
        cd $DATA_PATH
fi

#cd experiment-fork-20-12-18/

echo  "\"Experiment\"","\"CPU Time(Secs)\"","\"Method Name\"" 
#Experiment,CPU Time,Method Name

for filename in test.*.er; do 
	#echo -e "\"$filename\",\c" &&
		er_print  -printmode "," -sort i.totalcpu -metrics i.totalcpu -header  -func $filename  | grep "eu.prismacloud.primitives.zkpgs" | awk -v var="$filename" 'BEGIN{OFS="";}{ print "\""var"\",",$0 }'
#er_print  -printmode "," -sort i.totalcpu -metrics i.totalcpu -header  -func $filename  | grep "eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair.keyGen(eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters)" 
done 
