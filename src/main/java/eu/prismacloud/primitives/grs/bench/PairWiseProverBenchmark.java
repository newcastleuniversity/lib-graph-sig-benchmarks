package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.prover.PairWiseDifferenceProver;
import eu.prismacloud.primitives.zkpgs.store.URN;
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
 * Creates a benchmark for measuring the pre/post challenge phase of the pair wise prover component
 */

@State(Scope.Benchmark)
public class PairWiseProverBenchmark extends GSBenchmark {

	public static final String DATA_RESULTS_PAIR_WISE_PROVER_CSV = "data/results-pair-wise-prover-raw";

	private static ProverOrchestratorPerf prover;

	@State(Scope.Benchmark)
	@BenchmarkMode({Mode.AverageTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PreChallengeBenchmark extends PairWiseProverBenchmark {
		private List<PairWiseDifferenceProver> pairWiseDifferenceProvers;

		public PreChallengeBenchmark() {
			super();
		}

		@Setup(Level.Invocation)
		public void setup() throws ClassNotFoundException, ExecutionException, EncodingException, InterruptedException, IOException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
			super.setup();
			prover = getProver();
			prover.executeCompoundPreChallengePhaseForPairWiseProver();
			pairWiseDifferenceProvers = prover.getPairWiseDifferenceProvers();
		}

		@Benchmark
		@BenchmarkMode({Mode.AverageTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public void executeCommitmentProvers(PreChallengeBenchmark state) throws Exception {
			prover.computePairWiseProvers(pairWiseDifferenceProvers);
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
		}
	}

	@State(Scope.Benchmark)
	@BenchmarkMode({Mode.AverageTime})
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class PostChallengeBenchmark extends PairWiseProverBenchmark {
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
			prover.postChallengePhaseForPairWiseProver(challenge);

		}

		@Benchmark
		@BenchmarkMode({Mode.AverageTime})
		@OutputTimeUnit(TimeUnit.MILLISECONDS)
		public Map<URN, BigInteger> executePostChallengePhase(PostChallengeBenchmark state) throws Exception {
			return prover.executePostChallengePhaseForPairWiseProvers(challenge);
		}

		@TearDown(Level.Invocation)
		public void afterInvocation() throws Exception {
			prover = null;
		}
	}

	public static void main(String[] args) throws FileNotFoundException, RunnerException {
		Options opt = new OptionsBuilder()
				.include(eu.prismacloud.primitives.grs.bench.PairWiseProverBenchmark.class.getSimpleName())
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
		return new PrintStream(new File(DATA_RESULTS_PAIR_WISE_PROVER_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}
