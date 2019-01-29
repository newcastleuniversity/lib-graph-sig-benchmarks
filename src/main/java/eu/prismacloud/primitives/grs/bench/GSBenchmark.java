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
import java.util.Map;
import java.util.Vector;
import java.util.concurrent.ExecutionException;

/**
 * Created by Ioannis Sfyrakis on 2019-01-27
 */
@State(Scope.Benchmark)
public abstract class GSBenchmark {


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

	public VerifierOrchestrator getVerifier() {
		return verifier;
	}

	private static RecipientOrchestrator recipient;
	private static MockMessageGateway messageGateway;
	private static ProverOrchestratorPerf prover;
	private static VerifierOrchestrator verifier;
	public void GSBenchmark() {

	}

	public void setup() throws IOException, EncodingException, ClassNotFoundException, InterruptedException, ExecutionException, ProofStoreException, NoSuchAlgorithmException, VerificationException, ImportException, NoSuchFieldException, IllegalAccessException {
		// calculate number of bases for vertices and edges
		l_V = bases / 5;
		l_E = bases - (bases / 5);
		String sigmaFilename = "signer-infra-" + l_n + "-" + l_V + "-" + l_E + ".ser";
		String hostAddress = "192.168.0.19";
		int portNumber = 9998;

		messageGateway = new MockMessageGateway(DefaultValues.CLIENT, hostAddress, portNumber);

		setupIssuing(sigmaFilename);
		prover = new ProverOrchestratorPerf(ekp.getExtendedPublicKey(), messageGateway);
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

	public void setupIssuing(String sigmaFilename) throws IOException, ClassNotFoundException, EncodingException, ProofStoreException, NoSuchAlgorithmException, ImportException, VerificationException {

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


}
