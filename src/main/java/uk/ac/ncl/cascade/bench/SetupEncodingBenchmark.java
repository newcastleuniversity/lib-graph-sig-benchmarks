package uk.ac.ncl.cascade.bench;

import uk.ac.ncl.cascade.zkpgs.exception.EncodingException;
import uk.ac.ncl.cascade.zkpgs.keys.ExtendedKeyPair;
import uk.ac.ncl.cascade.zkpgs.keys.SignerKeyPair;
import uk.ac.ncl.cascade.zkpgs.parameters.GraphEncodingParameters;
import uk.ac.ncl.cascade.zkpgs.parameters.KeyGenParameters;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.math.BigInteger;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for generating vertex prime representatives. The vertex prime representatives are generated for graph sizes of 1000 - 10000 vertices.
 * Usage: java -cp target/benchmarks.jar  uk.ac.ncl.cascade.grs.bench.SetupEncodingBenchmark
 */
@State(Scope.Benchmark)
public class SetupEncodingBenchmark {

	public static final String DATA_RESULTS_KEYGEN_RAW_CSV = "data/results-setup-encoding-raw";

	@Param({"512", "1024", "2048", "3072"})
	private int l_n;

	private Map<String, Integer> grFileToBases;
	private int bases;

	@Param({"signer-infra-1000.graphml", "signer-infra-2000.graphml", "signer-infra-3000.graphml", "signer-infra-4000.graphml", "signer-infra-5000.graphml", "signer-infra-6000.graphml", "signer-infra-7000.graphml", "signer-infra-8000.graphml", "signer-infra-9000.graphml", "signer-infra-10000.graphml"})
//	@Param({"signer-infra-2000.graphml"})
	private String graphFilename;

	private int l_V;

	private int l_E;
	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;
	private ExtendedKeyPair ekp;
	private GraphEncodingParameters graphEncParams;
	private BigInteger vertexPrimeRepresentative;

	@Setup
	public void setup() throws IOException, ClassNotFoundException {
		int l_v = 2724;

		// configure graph filename to number of bases mapping for the graph encoding
		grFileToBases = new HashMap<String, Integer>();
		grFileToBases.put("signer-infra-1000.graphml", 1000);
		grFileToBases.put("signer-infra-2000.graphml", 2000);
		grFileToBases.put("signer-infra-3000.graphml", 3000);
		grFileToBases.put("signer-infra-4000.graphml", 4000);
		grFileToBases.put("signer-infra-5000.graphml", 5000);
		grFileToBases.put("signer-infra-6000.graphml", 6000);
		grFileToBases.put("signer-infra-7000.graphml", 7000);
		grFileToBases.put("signer-infra-8000.graphml", 8000);
		grFileToBases.put("signer-infra-9000.graphml", 9000);
		grFileToBases.put("signer-infra-10000.graphml", 10000);

		bases = grFileToBases.get(graphFilename);

		// calculate number of bases for vertices and edges
		l_V = bases;
		l_E = bases - (bases / 4); //- (bases / 5);
		gsk = new SignerKeyPair();
		keyGenParameters = KeyGenParameters.createKeyGenParameters(l_n, 1632, 256, 256, 1, 597, 120, l_v, 80, 256, 80, 80);
		if (l_n == 3072) l_v = l_v + 1024;
		if (l_n == 4096) l_v = l_v + 2048;

		graphEncParams = new GraphEncodingParameters(l_V, 120, l_E, 256, 16);

		vertexPrimeRepresentative = this.graphEncParams.getLeastVertexRepresentative();
//		System.out.println("vPrime bitlength: " + vertexPrimeRepresentative.bitLength());
//		System.out.println("\n vPrime: " + vertexPrimeRepresentative + "\n");
//		System.out.println("\n l_V: " + l_V + "\n");
//		System.out.println("\n l_E: " + l_E + "\n");

	}

	@Benchmark
	@BenchmarkMode({Mode.SingleShotTime})
	@Timeout(time = 1, timeUnit = TimeUnit.HOURS)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public void measureSetupEncoding(Blackhole blackhole) throws EncodingException {
		for (int i = 0; i < this.graphEncParams.getL_V(); i++) {
			if (i == 0) {
				vertexPrimeRepresentative = this.graphEncParams.getLeastVertexRepresentative();
				System.out.println("\n first: " + vertexPrimeRepresentative);
				System.out.println("\n first bitlength: " + vertexPrimeRepresentative.bitLength());
			} else {
				blackhole.consume(vertexPrimeRepresentative = vertexPrimeRepresentative.nextProbablePrime());
				System.out.println("\n second : " + vertexPrimeRepresentative);
				System.out.println("\n second bitlength: " + vertexPrimeRepresentative.bitLength());
			}
//			if (!CryptoUtilsFacade.isInRange(
//					vertexPrimeRepresentative,
//					this.graphEncParams.getLeastVertexRepresentative(),
//					this.graphEncParams.getUpperBoundVertexRepresentatives())) {
//				throw new EncodingException(
//						"The graph encoding attempted to "
//								+ "create a vertex representative outside of the designated range.");
//			}

		}
	}

	public static void main(String[] args) throws RunnerException, FileNotFoundException {

		Options opt = new OptionsBuilder()
				.include(SetupEncodingBenchmark.class.getSimpleName())
				//.param("l_n", "512", "1024", "2048", "3072")
				.param("l_n", "512")
				.jvmArgs("-server")
				.jvmArgs("-Xms2048m", "-Xmx3072m")
				.warmupIterations(0)
//				.addProfiler(YourkitProfiler.class)
				.warmupForks(5)
				.measurementIterations(1)
				.threads(1)
				.forks(100)
				.shouldFailOnError(true)
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
