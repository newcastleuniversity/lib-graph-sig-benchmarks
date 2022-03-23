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
 * Creates a benchmark for measuring issuing of binding credentials in a topology
 */

@State(Scope.Benchmark)
public class IssuingBCBenchmark {
	public static final String DATA_RESULTS_ISSUING_RAW_CSV = "data/results-issuing-raw";

	@Param({"2048"})
	private int l_n;

//	@Param({"200", "2000", "20000"})
	private int bases;
	
	@Param({"signer-infra-5.graphml"})
	private String graphFilename;// = "signer-infra-10000.graphml";
	
	//	@Param({"10", "100", "1000", "10000"})
	private int l_V;

	//	@Param({"50", "500", "5000", "50000"})
	private int l_E;

	private static SignerOrchestratorBC signer;
	private static RecipientOrchestratorBC recipient;
	private KeyGenParameters keyGenParameters;
	private SignerKeyPair gsk;
	private ExtendedPublicKey epk;
	private FilePersistenceUtil persistenceUtil;
	private GraphEncodingParameters graphEncParams;
	private ExtendedKeyPair ekp;
	private MockMessageGateway messageGateway;
	private static String sigmaFilename;
	private Map<String, Integer> grFileToBases;

	public void setup() throws IOException, EncodingException, ClassNotFoundException, InterruptedException, ExecutionException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {

		// configure graph filename to number of bases mapping for the graph encoding
		grFileToBases = new HashMap<String, Integer>();
		grFileToBases.put("signer-infra-5.graphml", 600);
//		grFileToBases.put("signer-infra-2000.graphml", 12000);
//		grFileToBases.put("signer-infra-3000.graphml", 17000);
//		grFileToBases.put("signer-infra-4000.graphml", 21000);
//		grFileToBases.put("signer-infra-5000.graphml", 26000);
//		grFileToBases.put("signer-infra-6000.graphml", 31000);
//		grFileToBases.put("signer-infra-7000.graphml", 36000);
//		grFileToBases.put("signer-infra-8000.graphml", 41000);
//		grFileToBases.put("signer-infra-9000.graphml", 46000);
//		grFileToBases.put("signer-infra-10000.graphml", 51000);

		bases = grFileToBases.get(graphFilename);

		// calculate number of bases for vertices and edges
		l_V = bases / 5;
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
	    BigInteger pseudonym = new BigInteger(NG,16);
		BigInteger e_i = new BigInteger("625843652583480414029392463292031");
		signer = new SignerOrchestratorBC(pseudonym, e_i, ekp, messageGateway);
		recipient = new RecipientOrchestratorBC( ekp.getExtendedPublicKey(), messageGateway);

		try {
			signer.init();
			recipient.init();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	@State(Scope.Benchmark)
	@OutputTimeUnit(TimeUnit.MILLISECONDS)
	public static class SerializeGSBenchmark extends IssuingBCBenchmark {
		public SerializeGSBenchmark() {
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
				.include(IssuingBCBenchmark.class.getSimpleName())
				.param("l_n", "2048")
				.jvmArgs("-server")
				.jvmArgs("-Xms2048m", "-Xmx3072m")
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
		return new PrintStream(new File(DATA_RESULTS_ISSUING_RAW_CSV + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}
}
