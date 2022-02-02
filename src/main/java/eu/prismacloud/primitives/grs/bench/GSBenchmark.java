package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.BaseRepresentation;
import eu.prismacloud.primitives.zkpgs.DefaultValues;
import eu.prismacloud.primitives.zkpgs.exception.EncodingException;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.exception.VerificationException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedKeyPair;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.keys.SignerKeyPair;
import eu.prismacloud.primitives.zkpgs.orchestrator.RecipientOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.SignerOrchestrator;
import eu.prismacloud.primitives.zkpgs.orchestrator.VerifierOrchestrator;
import eu.prismacloud.primitives.zkpgs.parameters.GraphEncodingParameters;
import eu.prismacloud.primitives.zkpgs.parameters.KeyGenParameters;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.FilePersistenceUtil;
import org.jgrapht.io.ImportException;
import org.openjdk.jmh.annotations.Param;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.State;

import java.io.File;
import java.io.IOException;
import java.math.BigInteger;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;
import java.util.concurrent.ExecutionException;

/**
 * Configure benchmarks for proving and verifying
 */
@State(Scope.Benchmark)
public abstract class GSBenchmark {

//	@Param({"512", "1024", "2048", "3072"})
	@Param({"2048"})
	private int l_n;

//	@Param({"200", "2000", "20000"})
	private int bases;

//	@Param({"signer-infra-1000.graphml", "signer-infra-2000.graphml", "signer-infra-3000.graphml", "signer-infra-4000.graphml", "signer-infra-5000.graphml", "signer-infra-6000.graphml", "signer-infra-7000.graphml", "signer-infra-8000.graphml", "signer-infra-9000.graphml", "signer-infra-10000.graphml"})
	@Param({"signer-infra-5.graphml"})
	private String graphFilename;

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
	private String ekpFilename;
	private ProverOrchestratorBCPerf provervc;
	private VerifierOrchestratorBCPerf verifiervc;

	public ExtendedPublicKey getEpk() {
		return epk;
	}

	public ExtendedKeyPair getEkp() {
		return ekp;
	}

	public SignerOrchestrator getSigner() {
		return signer;
	}

	public RecipientOrchestrator getRecipient() {
		return recipient;
	}

	public ProverOrchestratorPerf getProver() {
		return prover;
	}
	public ProverOrchestratorBCPerf getProverVC() {
		return provervc;
	}

	public VerifierOrchestrator getVerifier() {
		return verifier;
	}
	public VerifierOrchestratorBCPerf getVerifierVC() {
		return verifiervc;
	}

	private static RecipientOrchestrator recipient;
	private static MockMessageGateway messageGateway;
	private static ProverOrchestratorPerf prover;
	private static VerifierOrchestrator verifier;
	private Map<String, Integer> grFileToBases;

	public void GSBenchmark() {

	}

	public void setup() throws IOException, EncodingException, ClassNotFoundException, InterruptedException, ExecutionException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {

		// configure graph filename to number of bases mapping for the graph encoding
		grFileToBases = new HashMap<String, Integer>();
		grFileToBases.put("signer-infra-5.graphml", 600);

//		grFileToBases.put("signer-infra-1000.graphml", 7000);
//		grFileToBases.put("signer-infra-2000.graphml", 12000);
//		grFileToBases.put("signer-infra-3000.graphml", 17000);
//		grFileToBases.put("signer-infra-4000.graphml", 21000);
//		grFileToBases.put("signer-infra-5000.graphml", 26000);
//		grFileToBases.put("signer-infra-6000.graphml", 31000);
//		grFileToBases.put("signer-infra-7000.graphml", 52000);
//		grFileToBases.put("signer-infra-8000.graphml", 45000);
//		grFileToBases.put("signer-infra-9000.graphml", 48000);
//		grFileToBases.put("signer-infra-10000.graphml", 53000);

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
		if (new File(ekpFilename).isFile()){
			ekp = (ExtendedKeyPair) persistenceUtil.read(ekpFilename);
		}


		if (!new File(sigmaFilename).isFile()) {
			setupIssuing(sigmaFilename);
		}
		
		prover = new ProverOrchestratorPerf(ekp.getExtendedPublicKey(), messageGateway);
		verifier = new VerifierOrchestrator(ekp.getExtendedPublicKey(), messageGateway);
		prover.readSignature(sigmaFilename);
		Vector<Integer> vector = new Vector<>();

		// add proof vectors
		vector.add(1);
		vector.add(3);

		verifier.createQuery(vector);
		verifier.init();
		prover.init();

	}

	public void setupIssuing(String sigmaFilename) throws IOException, ClassNotFoundException, EncodingException, ProofStoreException, NoSuchAlgorithmException, ImportException, VerificationException {

		String signerKeyPairFilename = "SignerKeyPair-" + l_n + ".ser";
		String signerPKFilename = "SignerPublicKey-" + l_n + ".ser";
		String ekpFilename = "ExtendedKeyPair-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String epkFilename = "ExtendedPublicKey-" + l_n + "-" + l_V + "-" + l_E + ".ser";

		gsk = new SignerKeyPair();

		int l_v = 2724;
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
		baseCollection = epk.getBaseCollection();

		//		System.out.println("basecollection length: " + baseCollection.size());
		//		System.out.println("l_V: " + ekp.getGraphEncodingParameters().getL_V());
		//		System.out.println("l_E: " + ekp.getGraphEncodingParameters().getL_E());
		//		System.out.println("vertex bases: " + epk.getEncoding().);

//		String graphFilename = "/Users/alpac/DEV/lib-graph-sig-benchmarks/signer-infra.graphml";

//		signer = new SignerOrchestrator(ekp, messageGateway);
//		recipient = new RecipientOrchestrator(ekp.getExtendedPublicKey(), messageGateway);
		signer = new SignerOrchestrator(graphFilename, ekp, messageGateway);
		recipient = new RecipientOrchestrator(graphFilename, ekp.getExtendedPublicKey(), messageGateway);

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


}
