package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for generating keys with 512, 1024, 2048 and 3072 length
 */
@State(Scope.Benchmark)
public class KeyGenBenchmark {

	public static final String DATA_RESULTS_KEYGEN_RAW_CSV = "data/results-keygen-raw";
	
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
	@BenchmarkMode({Mode.AverageTime, Mode.Throughput,  Mode.SampleTime, Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.SECONDS)
	public void measureKeyGen() {
		gsk.keyGen(keyGenParameters);
	}

	public static void main(String[] args) throws RunnerException, FileNotFoundException {

		Options opt = new OptionsBuilder()
				.include(KeyGenBenchmark.class.getSimpleName())
				.forks(1)
				.param("l_n", "512", "1024", "2048", "3072")
				.warmupIterations(1)
				.jvmArgs("-server")
				.measurementIterations(1)
				.threads(1)
				.forks(1)
				.shouldFailOnError(true)
				//.shouldDoGC(true)
				.build();

		Collection<RunResult> res = new Runner(opt).run();
		PrintStream out = getPrintStream();
		RawCSVResultFormat rcsv = new RawCSVResultFormat(out, ",");
		rcsv.writeOut(res);

	}

	private static PrintStream getPrintStream() throws FileNotFoundException {
		Date date = new Date();
		Format formatter = new SimpleDateFormat("YYYY-MM-dd_hh-mm-ss");
		return new PrintStream(new File(DATA_RESULTS_KEYGEN_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}
