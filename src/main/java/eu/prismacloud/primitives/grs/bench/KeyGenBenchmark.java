package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.results.format.ResultFormatType;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for generating keys with 512, 1024, 2048 and 3072 length
 */
@State(Scope.Benchmark)
public class KeyGenBenchmark {


	@Param({"512", "1024", "2048", "3072"})
	private int l_n;

	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;


	@Setup
	public void setup() {
		gsk = new SignerKeyPair();
		keyGenParameters = KeyGenParameters.createKeyGenParameters(l_n, 1632, 256, 256, 1, 597, 120, 2724, 80, 256, 80, 80);
	}

	@Benchmark
	@BenchmarkMode({Mode.Throughput, Mode.AverageTime, Mode.SampleTime, Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.SECONDS)
	public void measureKeyGen() {
		gsk.keyGen(keyGenParameters);
	}

	public static void main(String[] args) throws RunnerException {

		Options opt = new OptionsBuilder()
				.include(KeyGenBenchmark.class.getSimpleName())
				.param("l_n", "512", "1024", "2048", "3072")
				.warmupIterations(5)
				.measurementIterations(10)
				.forks(2)
				.result("results-keygen.csv")
				.resultFormat(ResultFormatType.CSV)
				.build();

		new Runner(opt).run();

	}
}
