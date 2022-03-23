package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.DefaultValues;
import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedKeyPair;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
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
import uk.ac.ncl.cascade.binding.RecipientOrchestratorBC;
import uk.ac.ncl.cascade.binding.SignerOrchestratorBC;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.math.BigInteger;
import java.security.NoSuchAlgorithmException;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
/**
 * Creates a benchmark for measuring proving protocol for binding credentials between a prover and a verifier
 */
@State(Scope.Benchmark)
public class ProvingBCBenchmark extends GSBenchmark {


	public static final String DATA_RESULTS_PROVING_RAW_CSV = "data/results-proving-raw";
	private static ProverOrchestratorBCPerf prover;
	private static VerifierOrchestratorBCPerf verifier;
	private static SignerOrchestratorBC signer;
	private static RecipientOrchestratorBC recipient;
	private static String sigmaFilename;
	@Param({"signer-infra-5.graphml"})
	private String graphFilename;
	private Map<String, Integer> grFileToBases;
	private Integer bases;
	private String ekpFilename;
	@Param({"2048"})
	private int l_n;
	private FilePersistenceUtil persistenceUtil;
	private MockMessageGateway messageGateway;
	private ExtendedKeyPair ekp;
	//	@Param({"10", "100", "1000", "10000"})
	private int l_V;
	//	@Param({"50", "500", "5000", "50000"})
	private int l_E;
	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;
	private ExtendedPublicKey epk;
	private GraphEncodingParameters graphEncParams;

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(ProvingBCBenchmark.class.getSimpleName())
				//.param("l_n","512","1024", "2048", "3072")
				.param("l_n", "2048")
				.jvmArgs("-Xms3072m", "-Xmx4096m")
				.jvmArgs("-server")
				.warmupIterations(0)
				.addProfiler(YourkitProfiler.class)
				.warmupForks(10)
				.measurementIterations(1)
//				.timeout(TimeValue.minutes(30))
//				.warmupTime(TimeValue.minutes(30))
				.threads(1)
				.forks(25)
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
		return new PrintStream(new File(DATA_RESULTS_PROVING_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
	//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class PreChallengeBenchmark extends ProvingBenchmark {
//		public PreChallengeBenchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			prover = getProver();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void preChallenge(PreChallengeBenchmark state) throws Exception {
//			prover.executePreChallengePhase();
//		}
//
//		@TearDown(Level.Invocation)
//		public void afterInvocation() throws Exception {
//			prover = null;
//			verifier = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class ReceiveProverMessageBenchmark extends ProvingBenchmark {
//		public ReceiveProverMessageBenchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			prover = getProver();
//			prover.executePreChallengePhase();
//			BigInteger challenge = prover.computeChallenge();
//			prover.executePostChallengePhase(challenge);
//			verifier = getVerifier();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void proverMessage(ReceiveProverMessageBenchmark state) throws Exception {
//			verifier.receiveProverMessage();
//		}
//
//		@TearDown(Level.Invocation)
//		public void afterInvocation() throws Exception {
//			prover = null;
//			verifier = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class ExecuteVerificationBenchmark extends ProvingBenchmark {
//		public ExecuteVerificationBenchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			prover = getProver();
//			prover.executePreChallengePhase();
//			BigInteger challenge = prover.computeChallenge();
//			prover.executePostChallengePhase(challenge);
//			verifier = getVerifier();
//			verifier.receiveProverMessage();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void verification(ExecuteVerificationBenchmark state) throws Exception {
//			verifier.executeVerification();
//		}
//
//		@TearDown(Level.Invocation)
//		public void afterInvocation() throws Exception {
//			prover = null;
//			verifier = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class ComputeChallengeBenchmark extends ProvingBenchmark {
//		public ComputeChallengeBenchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			prover = getProver();
//			prover.executePreChallengePhase();
//			BigInteger challenge = prover.computeChallenge();
//			prover.executePostChallengePhase(challenge);
//			verifier = getVerifier();
//			verifier.receiveProverMessage();
//			verifier.executeVerification();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public BigInteger challenge(ComputeChallengeBenchmark state) throws Exception {
//			return verifier.computeChallenge();
//		}
//
//		@TearDown(Level.Invocation)
//		public void afterInvocation() throws Exception {
//			prover = null;
//			verifier = null;
//		}
//	}
//
//	@State(Scope.Benchmark)
//	@OutputTimeUnit(TimeUnit.MILLISECONDS)
//	public static class VerifyChallengeBenchmark extends ProvingBenchmark {
//		BigInteger challenge;
//
//		public VerifyChallengeBenchmark() {
//			super();
//		}
//
//		@Setup(Level.Invocation)
//		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//			super.setup();
//			prover = getProver();
//			prover.executePreChallengePhase();
//			BigInteger challenge = prover.computeChallenge();
//			prover.executePostChallengePhase(challenge);
//			verifier = getVerifier();
//			verifier.receiveProverMessage();
//			verifier.executeVerification();
//			challenge = verifier.computeChallenge();
//		}
//
//		@Benchmark
//		@BenchmarkMode({Mode.SingleShotTime})
//		@OutputTimeUnit(TimeUnit.MILLISECONDS)
//		public void challenge(VerifyChallengeBenchmark state) throws Exception {
//			verifier.verifyChallenge();
//		}
//
//		@TearDown(Level.Invocation)
//		public void afterInvocation() throws Exception {
//			prover = null;
//			verifier = null;
//		}
//	}

	@Override
	public void setup() throws IOException, EncodingException, ClassNotFoundException, InterruptedException, ExecutionException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
//
//
//		super.setup();

		// configure graph filename to number of bases mapping for the graph encoding
		grFileToBases = new HashMap<String, Integer>();
		grFileToBases.put("signer-infra-5.graphml", 600);

		bases = grFileToBases.get(graphFilename);

		// calculate number of bases for vertices and edges
		l_V = bases / 5;
		l_E = bases - (bases / 4);
		String sigmaFilename = "signer-infra-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		ekpFilename = "ExtendedKeyPair-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String hostAddress = "192.168.0.19";
		int portNumber = 9998;
		persistenceUtil = new FilePersistenceUtil();

		messageGateway = new MockMessageGateway(DefaultValues.CLIENT, hostAddress, portNumber);
		if (new File(ekpFilename).isFile()) {
			ekp = (ExtendedKeyPair) persistenceUtil.read(ekpFilename);
		}


		if (!new File(sigmaFilename).isFile()) {
			setupIssuing(sigmaFilename);
		}

		prover = new ProverOrchestratorBCPerf(ekp.getExtendedPublicKey(), messageGateway);
		verifier = new VerifierOrchestratorBCPerf(ekp.getExtendedPublicKey(), messageGateway);
		prover.readSignature(sigmaFilename);
		verifier.init();
		prover.init();
	}

	@Override
	public void setupIssuing(String sigmaFilename) throws EncodingException, IOException, ClassNotFoundException, ProofStoreException, NoSuchAlgorithmException, VerificationException {
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

		graphEncParams = new GraphEncodingParameters(l_V, 120, l_E, 256, 16);

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
		String NG = "23998E2A7765B6C913C0ED47D9CB3AC03DB4597D1C4438D61C9FD3418F3D78FFADC59E451FE25A28DD91CEDC59E40980BAE8A176EBEECE412F13466862BFFC3077BB9D26FEB8244ACD4B8D8C868E0095E6AC4122B148FE6F398073111DDCAB8194531CFA8D487B70223CF750E653190732F8BA2A2F7D2BFE2ED175A936BBC7671FC0BB9E45276F81A527F06ABBCC0AFFEDC994BF66D9EB69CC7B61F691FFAB1F78BC6E890A92E332E49519056F502F07206E69E6C182B135D785101DCA408E4F484768854CEAFA0C76355F4";
		BigInteger pseudonym = new BigInteger(NG, 16);
		BigInteger e_i = new BigInteger("625843652583480414029392463292031");
		signer = new SignerOrchestratorBC(pseudonym, e_i, ekp, messageGateway);
		recipient = new RecipientOrchestratorBC(ekp.getExtendedPublicKey(), messageGateway);

		try {
			signer.init();
			recipient.init();
			signer.round0();
			recipient.round1();
			signer.round2();
			recipient.round3();
			recipient.serializeFinalSignature(sigmaFilename);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class ProvingVerifyingBenchmark extends ProvingBCBenchmark {
		BigInteger challenge;

		public ProvingVerifyingBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@Timeout(time = 1, timeUnit = TimeUnit.HOURS)
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void compute(ProvingVerifyingBenchmark state) throws Exception {
//			prover = getProverVC();
			prover.executePreChallengePhase();
			BigInteger challenge = prover.computeChallenge();
			prover.executePostChallengePhase(challenge);
//			verifier = getVerifierVC();
			verifier.receiveProverMessage();
			verifier.executeVerification();
			challenge = verifier.computeChallenge();
			verifier.verifyChallenge();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
			verifier = null;
		}
	}
}

