package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.BaseRepresentation;
import eu.prismacloud.primitives.zkpgs.DefaultValues;
import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedKeyPair;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.orchestrator.ProverOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.RecipientOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.SignerOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.VerifierOrchestrator;
import eu.prismacloud.primitives.zkpgs.parameters.GraphEncodingParameters;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.FilePersistenceUtil;
import org.jgrapht.io.ImportException;
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
import java.security.NoSuchAlgorithmException;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.Map;
import java.util.Vector;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

@State(Scope.Benchmark)
public class ProvingBenchmark {
	/**
	 * Creates a benchmark for measuring proving protocol between a prover and a verifier
	 */

	public static final String DATA_RESULTS_PROVING_RAW_CSV = "data/results-proving-raw";

	@Param({"512", "1024", "2048", "3072"})
	private int l_n;

	@Param({"100", "1000", "10000", "100000"})
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
	private static SignerOrchestrator signer;
	private static RecipientOrchestrator recipient;
	private static MockMessageGateway messageGateway;
	private static ProverOrchestrator prover;
	private static VerifierOrchestrator verifier;

	public void setup() throws IOException, EncodingException, ClassNotFoundException, InterruptedException, ExecutionException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException {
		// calculate number of bases for vertices and edges
		l_V = bases / 5;
		l_E = bases - (bases / 5);
		String sigmaFilename = "signer-infra-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String hostAddress = "192.168.0.19";
		int portNumber = 9998;

		messageGateway = new MockMessageGateway(DefaultValues.CLIENT, hostAddress, portNumber);

		//	if (!new File(sigmaFilename).isFile()) {
		setupIssuing(sigmaFilename);
//		}
		System.out.println("---- prover verifier -----");
		prover = new ProverOrchestrator(ekp.getExtendedPublicKey(), messageGateway);
		verifier = new VerifierOrchestrator(ekp.getExtendedPublicKey(), messageGateway);
		prover.readSignature(sigmaFilename);
		Vector<Integer> vector = new Vector<>();
		// add proof vectors
		vector.add(1);
		vector.add(12);
		verifier.createQuery(vector);
		verifier.init();
		prover.init();

	}

	private void setupIssuing(String sigmaFilename) throws IOException, ClassNotFoundException, EncodingException, ProofStoreException, NoSuchAlgorithmException, ImportException, VerificationException {

		String signerKeyPairFilename = "SignerKeyPair-" + l_n + ".ser";
		String signerPKFilename = "SignerPublicKey-" + l_n + ".ser";
		String ekpFilename = "ExtendedKeyPair-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String epkFilename = "ExtendedPublicKey-" + l_n + "-" + l_V + "-" + l_E + ".ser";

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

		//		System.out.println("basecollection length: " + baseCollection.size());
		//		System.out.println("l_V: " + ekp.getGraphEncodingParameters().getL_V());
		//		System.out.println("l_E: " + ekp.getGraphEncodingParameters().getL_E());
		//		System.out.println("vertex bases: " + epk.getEncoding().);

		String graphFilename = "/Users/alpac/DEV/lib-graph-sig-benchmarks/signer-infra.graphml";

		signer = new SignerOrchestrator(ekp, messageGateway);
		recipient = new RecipientOrchestrator(ekp.getExtendedPublicKey(), messageGateway);

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
	@BenchmarkMode({Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PreChallengeBenchmark extends ProvingBenchmark {
		public PreChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException {
			super.setup();
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void preChallenge(PreChallengeBenchmark state) throws Exception {
			prover.executePreChallengePhase();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			signer = null;
			recipient = null;
			prover = null;
			verifier = null;
		}
	}

	@State(Scope.Benchmark)
	@BenchmarkMode({Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class ReceiveProverMessageBenchmark extends ProvingBenchmark {
		public ReceiveProverMessageBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException {
			super.setup();
			prover.executePreChallengePhase();
			BigInteger challenge = prover.computeChallenge();
			prover.executePostChallengePhase(challenge);
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void proverMessage(ReceiveProverMessageBenchmark state) throws Exception {
			//	System.out.print("verifier: " + verifier);
			verifier.receiveProverMessage();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			signer = null;
			recipient = null;
			prover = null;
			verifier = null;
		}
	}

	@State(Scope.Benchmark)
	@BenchmarkMode({Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class ExecuteVerificationBenchmark extends ProvingBenchmark {
		public ExecuteVerificationBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException {
			super.setup();
			prover.executePreChallengePhase();
			BigInteger challenge = prover.computeChallenge();
			prover.executePostChallengePhase(challenge);
			verifier.receiveProverMessage();
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void verification(ExecuteVerificationBenchmark state) throws Exception {
			verifier.executeVerification();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			signer = null;
			recipient = null;
			prover = null;
			verifier = null;
		}
	}

	@State(Scope.Benchmark)
	@BenchmarkMode({Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class ComputeChallengeBenchmark extends ProvingBenchmark {
		public ComputeChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException {
			super.setup();
			prover.executePreChallengePhase();
			BigInteger challenge = prover.computeChallenge();
			prover.executePostChallengePhase(challenge);
			verifier.receiveProverMessage();
			verifier.executeVerification();
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public BigInteger challenge(ComputeChallengeBenchmark state) throws Exception {
			return verifier.computeChallenge();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			signer = null;
			recipient = null;
			prover = null;
			verifier = null;
		}
	}

	@State(Scope.Benchmark)
	@BenchmarkMode({Mode.SingleShotTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class VerifyChallengeBenchmark extends ProvingBenchmark {
		BigInteger challenge;

		public VerifyChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException {
			super.setup();
			prover.executePreChallengePhase();
			BigInteger challenge = prover.computeChallenge();
			prover.executePostChallengePhase(challenge);
			verifier.receiveProverMessage();
			verifier.executeVerification();
			challenge = verifier.computeChallenge();
		}

		@Benchmark
		@BenchmarkMode({Mode.SingleShotTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void challenge(VerifyChallengeBenchmark state) throws Exception {
			verifier.verifyChallenge();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			signer = null;
			recipient = null;
			prover = null;
			verifier = null;
		}
	}

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.ProvingBenchmark.class.getSimpleName())
				.param("l_n", "512")//, "1024", "2048", "3072")
				.param("bases", "100")//, "1000", "10000", "100000")
				.jvmArgs("-server")
				.warmupIterations(0)
				//				.addProfiler(SolarisStudioProfiler.class)
				.warmupForks(1)
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
		return new PrintStream(new File(DATA_RESULTS_PROVING_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}

