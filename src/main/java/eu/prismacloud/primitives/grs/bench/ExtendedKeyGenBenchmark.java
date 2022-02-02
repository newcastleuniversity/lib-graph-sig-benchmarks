package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedKeyPair;
import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.parameters.GraphEncodingParameters;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
//import net.nicoulaj.jmh.profilers.SolarisStudioProfiler;
import net.nicoulaj.jmh.profilers.YourkitProfiler;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;
import org.openjdk.jmh.runner.options.TimeValue;
import org.openjdk.jmh.runner.options.WarmupMode;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for generating extended key pairs with 512, 1024, 2048 and 3072 key length. The extended keys are generated with the bases required for a a graph sizes of 1000 - 10000 vertices.
 * Usage: java -cp target/benchmarks.jar  eu.prismacloud.primitives.grs.bench.ExtendedKeyGenBenchmark
 */
@State(Scope.Benchmark)
public class ExtendedKeyGenBenchmark {

	public static final String DATA_RESULTS_KEYGEN_RAW_CSV = "data/results-keygen-raw";

	@Param({"512", "1024", "2048", "3072"})
	private int l_n;

	private Map<String, Integer> grFileToBases;
	private int bases;

//	@Param({"signer-infra-1000.graphml", "signer-infra-2000.graphml", "signer-infra-3000.graphml", "signer-infra-4000.graphml", "signer-infra-5000.graphml", "signer-infra-6000.graphml", "signer-infra-7000.graphml", "signer-infra-8000.graphml", "signer-infra-9000.graphml", "signer-infra-10000.graphml"})
	@Param({"signer-infra-10000.graphml"})
	private String graphFilename;

	private int l_V;

	private int l_E;
	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;
	private ExtendedKeyPair ekp;
	private GraphEncodingParameters graphEncParams;

	@Setup
	public void setup() {
		int l_v = 2724;

		// configure graph filename to number of bases mapping for the graph encoding
		grFileToBases = new HashMap<String, Integer>();
		grFileToBases.put("signer-infra-1000.graphml", 7000);
		grFileToBases.put("signer-infra-2000.graphml", 12000);
		grFileToBases.put("signer-infra-3000.graphml", 17000);
		grFileToBases.put("signer-infra-4000.graphml", 21000);
		grFileToBases.put("signer-infra-5000.graphml", 26000);
		grFileToBases.put("signer-infra-6000.graphml", 31000);
		grFileToBases.put("signer-infra-7000.graphml", 36000);
		grFileToBases.put("signer-infra-8000.graphml", 41000);
		grFileToBases.put("signer-infra-9000.graphml", 46000);
		grFileToBases.put("signer-infra-10000.graphml", 51000);

		bases = grFileToBases.get(graphFilename);

		// calculate number of bases for vertices and edges
		l_V = bases / 5;
		l_E = bases - (bases / 4); //- (bases / 5);
		gsk = new SignerKeyPair();
		keyGenParameters = KeyGenParameters.createKeyGenParameters(l_n, 1632, 256, 256, 1, 597, 120, l_v, 80, 256, 80, 80);
		if (l_n == 3072) l_v = l_v + 1024;
		if (l_n == 4096) l_v = l_v + 2048;

		graphEncParams = new GraphEncodingParameters(l_V, 120, l_E, 256, 16);
	}

	@Benchmark
	@BenchmarkMode({Mode.SingleShotTime})
	@Timeout(time = 1, timeUnit = TimeUnit.HOURS)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public void measureKeyGen() throws EncodingException {
		gsk.keyGen(keyGenParameters);
		ekp = new ExtendedKeyPair(gsk, graphEncParams, keyGenParameters);
		ekp.setupEncoding();
		ekp.generateBases();
		ekp.createExtendedKeyPair();
	}

	public static void main(String[] args) throws RunnerException, FileNotFoundException {

		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.ExtendedKeyGenBenchmark.class.getSimpleName())
				//.param("l_n", "512", "1024", "2048", "3072")
				.param("l_n",  "3072")
				.jvmArgs("-server")
				.jvmArgs("-Xms2048m", "-Xmx3072m")
				.warmupIterations(0)
				.addProfiler(YourkitProfiler.class)
				.warmupForks(5)
				.measurementIterations(1)
				//				.timeout(TimeValue.minutes(30))
				//				.warmupTime(TimeValue.minutes(30))
				.threads(1)
				.forks(100)
				.shouldFailOnError(true)
				//				.measurementTime(new TimeValue(1, TimeUnit.MINUTES)) // used for throughput benchmark
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
