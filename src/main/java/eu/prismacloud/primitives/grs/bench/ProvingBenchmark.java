package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.orchestrator.ProverOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.VerifierOrchestrator;
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
import java.math.BigInteger;
import java.security.NoSuchAlgorithmException;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

@State(Scope.Benchmark)
public class ProvingBenchmark extends GSBenchmark {
	/**
	 * Creates a benchmark for measuring proving protocol between a prover and a verifier
	 */

	public static final String DATA_RESULTS_PROVING_RAW_CSV = "data/results-proving-raw";

	private static ProverOrchestrator prover;
	private static VerifierOrchestrator verifier;

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

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class ProvingVerifyingBenchmark extends ProvingBenchmark {
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
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void compute(ProvingVerifyingBenchmark state) throws Exception {
			prover = getProver();
			prover.executePreChallengePhase();
			BigInteger challenge = prover.computeChallenge();
			prover.executePostChallengePhase(challenge);
			verifier = getVerifier();
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

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.ProvingBenchmark.class.getSimpleName())
				.param("l_n", "512", "1024", "2048", "3072")
				.param("bases", "400")//, "1000", "10000", "100000")
				.jvmArgs("-server")
				.warmupIterations(0)
				.addProfiler(YourkitProfiler.class)
				.warmupForks(5)
				.measurementIterations(1)
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
		return new PrintStream(new File(DATA_RESULTS_PROVING_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}

