package uk.ac.ncl.cascade.bench;

import uk.ac.ncl.cascade.zkpgs.exception.EncodingException;
import uk.ac.ncl.cascade.zkpgs.exception.ProofStoreException;
import uk.ac.ncl.cascade.zkpgs.exception.VerificationException;
import uk.ac.ncl.cascade.zkpgs.orchestrator.ProverOrchestrator;
import uk.ac.ncl.cascade.zkpgs.orchestrator.VerifierOrchestrator;
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
		@Timeout(time = 1, timeUnit = TimeUnit.HOURS)
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
				.include(ProvingBenchmark.class.getSimpleName())
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
}

