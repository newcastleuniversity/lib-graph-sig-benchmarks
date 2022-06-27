package uk.ac.ncl.cascade.bench;

import uk.ac.ncl.cascade.zkpgs.exception.EncodingException;
import uk.ac.ncl.cascade.zkpgs.exception.ProofStoreException;
import uk.ac.ncl.cascade.zkpgs.exception.VerificationException;
import uk.ac.ncl.cascade.zkpgs.orchestrator.ProverOrchestrator;
import uk.ac.ncl.cascade.zkpgs.prover.PossessionProver;
import uk.ac.ncl.cascade.zkpgs.store.URN;
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
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for measuring the pre/post challenge phase of the possession prover component
 * for binding credentials.
 */
@State(Scope.Benchmark)
public class PossessionProverBCBenchmark extends GSBenchmark {

	public static final String DATA_RESULTS_POSSESSION_PROVER_RAW_CSV = "data/results-possession-prover-raw";

	private static ProverOrchestratorPerf prover;

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PreChallengeBenchmark extends PossessionProverBenchmark {

		private PossessionProver pProver;

		public PreChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
			prover = getProver();
			prover.executeCompoundPreChallengePhaseForPossessionProver();
			pProver = prover.getPossessionProverValue();

		}

		@Benchmark
		@BenchmarkMode({Mode.AverageTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void executeCompoundPreChallengePhase(PreChallengeBenchmark state) throws Exception {
			pProver.executeCompoundPreChallengePhase();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
			pProver = null;
		}
	}

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PostChallengeBenchmark extends PossessionProverBenchmark {
		private Class<ProverOrchestrator> sProver;
		private BigInteger challenge;
		private PossessionProver pProver;

		public PostChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
			prover = getProver();
			prover.executePreChallengePhase();
			challenge = prover.computeChallenge();
			pProver = prover.getPossessionProverValue();
		}

		@Benchmark
		@BenchmarkMode({Mode.AverageTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public Map<URN, BigInteger> executePostChallengePhase(PostChallengeBenchmark state) throws Exception {
			return pProver.executePostChallengePhase(challenge);
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
			pProver = null;
		}
	}

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(PossessionProverBenchmark.class.getSimpleName())
				.param("l_n", "2048")//, "1024", "2048", "3072")
				.param("bases", "600")//, "1000", "10000", "100000")
				.jvmArgs("-server")
				.warmupIterations(0)
				//				.addProfiler(SolarisStudioProfiler.class)
				.warmupForks(10)
				.measurementIterations(1)
				.threads(1)
				.forks(25)
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
		return new PrintStream(new File(DATA_RESULTS_POSSESSION_PROVER_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}

