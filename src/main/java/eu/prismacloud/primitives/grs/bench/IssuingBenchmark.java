package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.DefaultValues;
import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedKeyPair;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.orchestrator.RecipientOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.SignerOrchestrator;
import eu.prismacloud.primitives.zkpgs.parameters.GraphEncodingParameters;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.FilePersistenceUtil;
import net.nicoulaj.jmh.profilers.YourkitProfiler;
import org.jgrapht.io.ImportException;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.results.RunResult;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.security.NoSuchAlgorithmException;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for measuring issuing of
 */

@State(Scope.Benchmark)
public class IssuingBenchmark {
	public static final String DATA_RESULTS_ISSUING_RAW_CSV = "data/results-issuing-raw";

	@Param({"512", "1024", "2048", "3072"})
	private int l_n;

	@Param({"200", "2000", "20000"})
	private int bases;

	//	@Param({"10", "100", "1000", "10000"})
	private int l_V;

	//	@Param({"50", "500", "5000", "50000"})
	private int l_E;

	private static SignerOrchestrator signer;
	private static RecipientOrchestrator recipient;
	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;
	private ExtendedPublicKey epk;
	private FilePersistenceUtil persistenceUtil;
	private GraphEncodingParameters graphEncParams;
	private ExtendedKeyPair ekp;
	private MockMessageGateway messageGateway;
	private static String sigmaFilename;

	public void setup() throws IOException, EncodingException, ClassNotFoundException, InterruptedException, ExecutionException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {

		// calculate number of bases for vertices and edges
		l_V = bases / 4;
		l_E = bases - (bases / 4); //- (bases / 5);
//		System.out.println("l_V: " + l_V);
//		System.out.println("l_E: " + l_E);
		sigmaFilename = "signer-infra-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String hostAddress = "192.168.0.19";
		int portNumber = 9998;
		messageGateway = new MockMessageGateway(DefaultValues.CLIENT, hostAddress, portNumber);
		setupIssuing(sigmaFilename);

	}

	public void setupIssuing(String sigmaFilename) throws IOException, ClassNotFoundException, EncodingException, ProofStoreException, NoSuchAlgorithmException, ImportException, VerificationException {

		String signerKeyPairFilename = "SignerKeyPair-" + l_n + ".ser";
		String signerPKFilename = "SignerPublicKey-" + l_n + ".ser";
		String ekpFilename = "ExtendedKeyPair-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String epkFilename = "ExtendedPublicKey-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		int l_v = 2724;
		persistenceUtil = new FilePersistenceUtil();
		gsk = new SignerKeyPair();

		if (l_n == 3072) l_v = l_v + 1024;
		if (l_n == 4096) l_v = l_v + 2048;

		System.out.println("lv: " + l_v);
		
		keyGenParameters = KeyGenParameters.createKeyGenParameters(l_n, 1632, 256, 256, 1, 597, 120, l_v, 80, 256, 80, 80);

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
		BaseCollection baseCollection = epk.getBaseCollection();

		//		System.out.println("basecollection length: " + baseCollection.size());
		//		System.out.println("l_V: " + ekp.getGraphEncodingParameters().getL_V());
		//		System.out.println("l_E: " + ekp.getGraphEncodingParameters().getL_E());
		//		System.out.println("vertex bases: " + epk.getEncoding().);

		String graphFilename = "signer-infra-50.graphml";

		signer = new SignerOrchestrator(graphFilename, ekp, messageGateway);
		recipient = new RecipientOrchestrator(graphFilename, ekp.getExtendedPublicKey(), messageGateway);

		try {
			signer.init();
			recipient.init();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class Round0Benchmark extends IssuingBenchmark {
//		public Round0Benchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void round0(Round0Benchmark state) throws Exception {
//			signer.round0();
//		}
//
//		@TearDown(Level.Invocation)
//		public void stop() throws Exception {
//			signer = null;
//			recipient = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class Round1Benchmark extends IssuingBenchmark {
//		public Round1Benchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			signer.round0();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void round1(Round1Benchmark state) throws Exception {
//			recipient.round1();
//		}
//
//		@TearDown(Level.Invocation)
//		public void stop() throws Exception {
//			signer = null;
//			recipient = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class Round2Benchmark extends IssuingBenchmark {
//		public Round2Benchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			System.out.println("round0: ");
//			signer.round0();
//			System.out.println("round1: ");
//			recipient.round1();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void round2(Round2Benchmark state) throws Exception {
//			System.out.println("round2: ");
//			signer.round2();
//		}
//
//
//		@TearDown(Level.Invocation)
//		public void stop() throws Exception {
//			signer = null;
//			recipient = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class Round3Benchmark extends IssuingBenchmark {
//		public Round3Benchmark() {
//			super();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void round3(Round3Benchmark state) throws Exception {
//			recipient.round3();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			signer.round0();
//			recipient.round1();
//			signer.round2();
//		}
//
//		@TearDown(Level.Invocation)
//		public void stop() throws Exception {
//			signer = null;
//			recipient = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class RoundAllBenchmark extends IssuingBenchmark {
//		public RoundAllBenchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void issuing(RoundAllBenchmark state) throws Exception {
//			signer.round0();
//			recipient.round1();
//			signer.round2();
//			recipient.round3();
//		}
//
//		@TearDown(Level.Invocation)
//		public void stop() throws Exception {
//			signer = null;
//			recipient = null;
//		}
//	}

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class SerializeGSBenchmark extends IssuingBenchmark {
		public SerializeGSBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void issuing(SerializeGSBenchmark state) throws Exception {
			signer.round0();
			recipient.round1();
			signer.round2();
			recipient.round3();
			recipient.serializeFinalSignature(sigmaFilename);
		}

		@TearDown(Level.Invocation)
		public void stop() throws Exception {
			signer = null;
			recipient = null;
		}
	}

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.IssuingBenchmark.class.getSimpleName())
				.param("l_n", "512", "1024", "2048", "3072")
				.param("bases", "400")//, "2000", "20000", "200000")
				.jvmArgs("-server")
				.warmupIterations(0)
				.addProfiler(YourkitProfiler.class)
				.warmupForks(1)
				.measurementIterations(1)
				.threads(1)
				.forks(1)
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
		return new PrintStream(new File(DATA_RESULTS_ISSUING_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}
