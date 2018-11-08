Graph Signature Library Benchmarks
----------------------------------

Executing the benchmarks requires the graph signature library to be present in the local maven repository.
The graph signature library can be installed by using the following maven command:
mvn install:install-file -Dfile=/path/to/target/graph-sig-0.0.1-SNAPSHOT.jar -DgroupId=prismacloud.primitives -DartifactId=graph-sig -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar

Run KeyGenBenchmark included in this project using the options specified in the main method of the class:
java -cp target/benchmarks.jar  eu.prismacloud.primitives.grs.bench.KeyGenBenchmark
