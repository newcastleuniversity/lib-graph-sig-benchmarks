package uk.ac.ncl.cascade.bench;

import uk.ac.ncl.cascade.zkpgs.keys.SignerKeyPair;
import uk.ac.ncl.cascade.zkpgs.parameters.KeyGenParameters;
//import net.nicoulaj.jmh.profilers.SolarisStudioProfiler;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;
import org.openjdk.jmh.runner.options.WarmupMode;

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
 * Usage: java -cp target/benchmarks.jar  uk.ac.ncl.cascade.grs.bench.KeyGenBenchmark
 *
 * Measuring Throughput (ops/time unit) needs to define the measurement time, which currently is set to 1 minute.
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
	// other benchmark modes include Mode.SampleTime and Mode.SingleShotTime
//	@BenchmarkMode({Mode.AverageTime, Mode.Throughput})
	@BenchmarkMode({Mode.AverageTime})
//	@BenchmarkMode({Mode.Throughput})
	@OutputTimeUnit(TimeUnit.MINUTES)
	//@Benchmark
	//@Warmup(iterations = 3, batchSize = 1)
	//@Measurement(iterations = 1, batchSize = 1)
	//@BenchmarkMode(Mode.SingleShotTime)
	public void measureKeyGen() {
		gsk.keyGen(keyGenParameters);
	}

	public static void main(String[] args) throws RunnerException, FileNotFoundException {

		Options opt = new OptionsBuilder()
				.include(KeyGenBenchmark.class.getSimpleName())
				.param("l_n", "512", "1024", "2048", "3072")
				.jvmArgs("-server")
				.warmupIterations(0)
				.measurementIterations(1)
//				.addProfiler(SolarisStudioProfiler.class)
//				.addProfiler(OraclePerformanceAnalyzerProfiler.class)
				.warmupMode(WarmupMode.INDI)
				.threads(1)
				.warmupForks(2)
				.forks(10)
				.shouldFailOnError(true)
			//	.measurementTime(new TimeValue(1, TimeUnit.MINUTES)) // used for throughput benchmark
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
