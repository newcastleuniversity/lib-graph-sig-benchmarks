package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.message.IMessageGateway;
import eu.prismacloud.primitives.zkpgs.store.ProofStore;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.store.URNType;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.GSLoggerConfiguration;
import eu.prismacloud.primitives.zkpgs.util.crypto.GroupElement;
import eu.prismacloud.primitives.zkpgs.verifier.PossessionVerifier;
import uk.ac.ncl.cascade.binding.VerifierOrchestratorBC;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigInteger;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Wrapper for verifier orchestrator used with jmh benchmarks
 */
public class VerifierOrchestratorBCPerf extends VerifierOrchestratorBC {
	private PossessionVerifier possessionVerifier;
	private BigInteger cChallenge;
	private GroupElement hatZ;
	private Logger gslog = GSLoggerConfiguration.getGSlog();
	private Method computeCommitmentVerifiersMethod;
	private Method computePairWiseVerifiersMethod;

	public VerifierOrchestratorBCPerf(ExtendedPublicKey extendedPublicKey, IMessageGateway messageGateway) {
		super(extendedPublicKey, messageGateway);
	}

	public PossessionVerifier getPossessionVerifier() {
		return possessionVerifier;
	}

	public BigInteger getcChallenge() {
		return cChallenge;
	}

	public Boolean executeVerificationForPossessionVerifier() throws NoSuchFieldException, IllegalAccessException {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();

		if (!super.checkLengths()) {
			return false;
		}

		BaseCollection baseCollection = (BaseCollection) getValueOfField("baseCollection");
		ExtendedPublicKey extendedPublicKey = (ExtendedPublicKey) getValueOfField("extendedPublicKey");
		ProofStore<Object> proofStore = (ProofStore<Object>) getValueOfField("proofStore");

		cChallenge = (BigInteger) getValueOfField("cChallenge");

		possessionVerifier = new PossessionVerifier(baseCollection, extendedPublicKey, proofStore);

		return true;
	}

	public Boolean executeVerificationForCommitmentVerifiers() throws NoSuchFieldException, IllegalAccessException, NoSuchMethodException {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();

		if (!super.checkLengths()) {
			return false;
		}

		BaseCollection baseCollection = (BaseCollection) getValueOfField("baseCollection");
		ExtendedPublicKey extendedPublicKey = (ExtendedPublicKey) getValueOfField("extendedPublicKey");
		ProofStore<Object> proofStore = (ProofStore<Object>) getValueOfField("proofStore");

		cChallenge = (BigInteger) getValueOfField("cChallenge");

		possessionVerifier = new PossessionVerifier(baseCollection, extendedPublicKey, proofStore);
		try {
			Map<URN, GroupElement> responses = possessionVerifier.executeCompoundVerification(this.cChallenge);
			String hatZURN = URNType.buildURNComponent(URNType.HATZ, PossessionVerifier.class);
			hatZ = responses.get(URN.createZkpgsURN(hatZURN));
			if (hatZ == null) {
				return false;
			}

		} catch (ProofStoreException e) {
			gslog.log(Level.SEVERE, "Could not access the challenge in the ProofStore.", e);
		}

		// get computeCommitmentVerifiers method
		computeCommitmentVerifiersMethod = superClass.getDeclaredMethod("computeCommitmentVerifiers");
		computeCommitmentVerifiersMethod.setAccessible(true);
		return true;

	}

	public boolean executeVerificationForPairWiseVerifiers() throws NoSuchMethodException, NoSuchFieldException, IllegalAccessException, InvocationTargetException {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();

		if (!super.checkLengths()) {
			return false;
		}

		BaseCollection baseCollection = (BaseCollection) getValueOfField("baseCollection");
		ExtendedPublicKey extendedPublicKey = (ExtendedPublicKey) getValueOfField("extendedPublicKey");
		ProofStore<Object> proofStore = (ProofStore<Object>) getValueOfField("proofStore");

		cChallenge = (BigInteger) getValueOfField("cChallenge");

		possessionVerifier = new PossessionVerifier(baseCollection, extendedPublicKey, proofStore);
		try {
			Map<URN, GroupElement> responses = possessionVerifier.executeCompoundVerification(this.cChallenge);
			String hatZURN = URNType.buildURNComponent(URNType.HATZ, PossessionVerifier.class);
			hatZ = responses.get(URN.createZkpgsURN(hatZURN));
			if (hatZ == null) {
				return false;
			}

		} catch (ProofStoreException e) {
			gslog.log(Level.SEVERE, "Could not access the challenge in the ProofStore.", e);
		}

		// get computeCommitmentVerifiers method
		computeCommitmentVerifiersMethod = superClass.getDeclaredMethod("computeCommitmentVerifiers");
		computeCommitmentVerifiersMethod.setAccessible(true);
		computeCommitmentVerifiersMethod.invoke(this);

		computePairWiseVerifiersMethod = superClass.getDeclaredMethod("computePairWiseVerifiers");
		computePairWiseVerifiersMethod.setAccessible(true);

		return true;
	}

	public Object executeCommitmentVerifiers() throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {

		return computeCommitmentVerifiersMethod.invoke(this);

	}

	public Object executePairWiseVerifiers() throws InvocationTargetException, IllegalAccessException {
		return computePairWiseVerifiersMethod.invoke(this);

	}

	private Object getValueOfField(String fieldName) throws NoSuchFieldException, IllegalAccessException {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();
		Field proverOrchestratorField = superClass.getDeclaredField(fieldName);
		proverOrchestratorField.setAccessible(true);

		return proverOrchestratorField.get(this);
	}
}
