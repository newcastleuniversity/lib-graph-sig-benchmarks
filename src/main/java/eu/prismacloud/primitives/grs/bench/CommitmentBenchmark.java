package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.BaseRepresentation;
import eu.prismacloud.primitives.zkpgs.commitment.GSCommitment;
import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedKeyPair;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.message.HttpMessageGateway;
import eu.prismacloud.primitives.zkpgs.parameters.GraphEncodingParameters;
//import net.nicoulaj.jmh.profilers.SolarisStudioProfiler;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
import eu.prismacloud.primitives.zkpgs.recipient.GSRecipient;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.FilePersistenceUtil;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;
import org.openjdk.jmh.runner.options.TimeValue;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.math.BigInteger;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for computing commitments with a number of bases and with a key with variable lengths (512, 1024, 2048, 3072)
 * Usage: java -cp target/benchmarks.jar  eu.prismacloud.primitives.grs.bench.CommitmentBenchmark
 * <p>
 * Measuring Throughput (ops/time unit) needs to define the measurement time, which currently is set to 1 minute.
 */
@State(Scope.Benchmark)
public class CommitmentBenchmark {

	public static final String DATA_RESULTS_KEYGEN_RAW_CSV = "data/results-commitment-raw";

	@Param({"512", "1024", "2048", "3072"})
	private int l_n;


	@Param({"50", "500", "5000", "50000"})
	private int bases;

//	@Param({"10", "100", "1000", "10000"})
	private int l_V;

//	@Param({"50", "500", "5000", "50000"})
	private int l_E;

	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;
	private ExtendedPublicKey epk;
	private BaseCollection baseCollection;
	private BigInteger randomness;
	private FilePersistenceUtil persistenceUtil;
	private GraphEncodingParameters graphEncParams;
	private ExtendedKeyPair ekp;
	private Map<URN, BaseRepresentation> encodedBases;

	@Setup
	public void setup() throws IOException, EncodingException, ClassNotFoundException {
		// calculate number of bases for vertices and edges
		l_V = bases/5;
		l_E = bases - (bases/5);
		
		String signerKeyPairFilename = "SignerKeyPair-" + l_n  + ".ser";
		String signerPKFilename = "SignerPublicKey-" + l_n + ".ser";
		String ekpFilename = "ExtendedKeyPair-" + l_n + l_V + l_E + ".ser";
		String epkFilename = "ExtendedPublicKey-" + l_n + l_V + l_E + ".ser";

		persistenceUtil = new FilePersistenceUtil();
		gsk = new SignerKeyPair();

		keyGenParameters = KeyGenParameters.createKeyGenParameters(l_n, 1632, 256, 256, 1, 597, 120, 2724, 80, 256, 80, 80);

		graphEncParams = new GraphEncodingParameters(l_V, 56, l_E, 256, 16);

		if (!new File(signerKeyPairFilename).isFile()) {
			gsk.keyGen(keyGenParameters);
			persistenceUtil.write(gsk, signerKeyPairFilename);
			persistenceUtil.write(gsk.getPublicKey(), signerPKFilename);
		} else {
			gsk = (SignerKeyPair) persistenceUtil.read(signerKeyPairFilename);
		}

		if (!new File(ekpFilename).isFile()) {
			ekp = new ExtendedKeyPair(gsk, graphEncParams, keyGenParameters);
			ekp.setupEncoding();

			ekp.generateBases();
			ekp.createExtendedKeyPair();
			persistenceUtil.write(ekp, ekpFilename);
		} else {
			ekp = (ExtendedKeyPair) persistenceUtil.read(ekpFilename);
		}


		epk = ekp.getExtendedPublicKey();

		persistenceUtil.write(ekp.getExtendedPublicKey(), epkFilename);
		baseCollection = epk.getBaseCollection();


		GSRecipient recipient = new GSRecipient(epk, new HttpMessageGateway("127.0.0.1", 78));
		randomness = recipient.generatevPrime();
		System.out.println("basecollection length: " + baseCollection.size());
		System.out.println("l_V: " + ekp.getGraphEncodingParameters().getL_V());
		System.out.println("l_E: " + ekp.getGraphEncodingParameters().getL_E());
//		System.out.println("vertex bases: " + epk.getEncoding().);

	}

	@Benchmark
	// other benchmark modes include Mode.SampleTime and Mode.SingleShotTime
	//	@BenchmarkMode({Mode.AverageTime, Mode.Throughput})
	@BenchmarkMode({Mode.AverageTime})
//	@BenchmarkMode({Mode.Throughput})
//	@OutputTimeUnit(TimeUnit.MINUTES)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public GSCommitment measureCommitments() {
		GSCommitment commitment = GSCommitment.createCommitment(baseCollection, randomness, epk);
		return commitment;
	}

	public static void main(String[] args) throws RunnerException, FileNotFoundException {

		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.CommitmentBenchmark.class.getSimpleName())
				.param("l_n", "512", "1024", "2048", "3072")
				.param("bases", "50", "500", "5000", "50000")
				.jvmArgs("-server")
				.warmupIterations(0)
//				.addProfiler(SolarisStudioProfiler.class)
				.warmupForks(1)
				.
				.measurementIterations(1)
				.threads(1)
				.forks(1)
				.shouldFailOnError(true)
				.measurementTime(new TimeValue(1, TimeUnit.MINUTES)) // used for throughput benchmark
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


