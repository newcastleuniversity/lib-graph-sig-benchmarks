package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.prover.CommitmentProver;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.util.crypto.GroupElement;
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
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

/**
 * Creates a benchmark for measuring the pre/post challenge phase of the commitment prover component
 */
@State(Scope.Benchmark)
public class CommitmentProverBenchmark extends GSBenchmark {

	public static final String DATA_RESULTS_COMMITMENT_PROVER_RAW_CSV = "data/results-commitment-prover-raw";

	private static ProverOrchestratorPerf prover;

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PreChallengeBenchmark extends CommitmentProverBenchmark {

		private List<CommitmentProver> commitmentProverList;
		private static int csize;

		public PreChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
			prover = getProver();
			prover.executeCompoundPreChallengePhaseForCommitmentProver();
			prover.createCommitmentProvers();
			commitmentProverList = prover.getCommitmentProverList();
			csize = commitmentProverList.size();
		}

		@Benchmark
		@BenchmarkMode({Mode.AverageTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public GroupElement executeCommitmentProvers(PreChallengeBenchmark state) throws Exception {
			return prover.computeCommitmentProvers();
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
		}
	}

	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PostChallengeBenchmark extends CommitmentProverBenchmark {
		private BigInteger challenge;

		public PostChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
			prover = getProver();
			prover.executePreChallengePhase();
			challenge = prover.computeChallenge();
			prover.postChallengePhaseForCommitmentProver(challenge);
		}

		@Benchmark
		@BenchmarkMode({Mode.AverageTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public Map<URN, BigInteger> executePostChallengePhase(PostChallengeBenchmark state) throws Exception {
			return prover.executePostChallengePhaseForCommitmentProvers(challenge);
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
		}
	}

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.CommitmentProverBenchmark.class.getSimpleName())
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
		return new PrintStream(new File(DATA_RESULTS_COMMITMENT_PROVER_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}

