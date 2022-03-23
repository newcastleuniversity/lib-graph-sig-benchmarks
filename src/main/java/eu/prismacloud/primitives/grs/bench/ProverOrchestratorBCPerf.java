package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.BaseRepresentation;
import eu.prismacloud.primitives.zkpgs.commitment.GSCommitment;
import eu.prismacloud.primitives.zkpgs.exception.ProofStoreException;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.message.IMessageGateway;
import eu.prismacloud.primitives.zkpgs.prover.CommitmentProver;
import eu.prismacloud.primitives.zkpgs.prover.PairWiseDifferenceProver;
import eu.prismacloud.primitives.zkpgs.prover.PossessionProver;
import eu.prismacloud.primitives.zkpgs.signature.GSSignature;
import eu.prismacloud.primitives.zkpgs.store.ProofStore;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.util.Assert;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.BaseIterator;
import eu.prismacloud.primitives.zkpgs.util.GSLoggerConfiguration;
import eu.prismacloud.primitives.zkpgs.util.crypto.GroupElement;
import uk.ac.ncl.cascade.binding.ProverOrchestratorBC;

import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Wrapper for prover orchestrator used with jmh benchmarks
 */
public class ProverOrchestratorBCPerf extends ProverOrchestratorBC {

	private PossessionProver possessionProverValue;
	private Logger gslog = GSLoggerConfiguration.getGSlog();

	private List<CommitmentProver> commitmentProverList;
	private BaseIterator vertexIterator;
	private GroupElement tildeCommitment;


	private List<PairWiseDifferenceProver> pairWiseDifferenceProvers;

	public ProverOrchestratorBCPerf(ExtendedPublicKey extendedPublicKey, IMessageGateway messageGateway) throws NoSuchFieldException {
		super(extendedPublicKey, messageGateway);
	}

	public PossessionProver getPossessionProverValue() throws NoSuchFieldException, IllegalAccessException {
		return (PossessionProver) getValueOfField("possessionProver");
	}

	public void executeCompoundPreChallengePhaseForPossessionProver() {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();
		try {
			// get required fields for blinded graph signature
			Field blindedGraphSignatureField = superClass.getDeclaredField("blindedGraphSignature");

			blindedGraphSignatureField.setAccessible(true);

			GSSignature gs = (GSSignature) getValueOfField("graphSignature");
			GSSignature blindedGS = gs.blind();

			blindedGraphSignatureField.set(this, blindedGS);

			// execute storeBlindedGS method
			Method storeBlindedGSMethod = superClass.getDeclaredMethod("storeBlindedGS");
			storeBlindedGSMethod.setAccessible(true);
			storeBlindedGSMethod.invoke(this);

			ExtendedPublicKey extendedPublicKeyValue = (ExtendedPublicKey) getValueOfField("extendedPublicKey");
			ProofStore proofStoreValue = (ProofStore) getValueOfField("proofStore");

			Field possessionProverField = superClass.getDeclaredField("possessionProver");
			possessionProverField.setAccessible(true);
			possessionProverValue = (PossessionProver) possessionProverField.get(this);

			this.possessionProverValue = new PossessionProver(blindedGS, extendedPublicKeyValue, proofStoreValue);
			possessionProverField.set(this, possessionProverValue);

		} catch (NoSuchFieldException | IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
			e.printStackTrace();
		}
	}


	public void executeCompoundPreChallengePhaseForCommitmentProver() {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();
		try {
			// get required fields for blinded graph signature
			Field blindedGraphSignatureField = superClass.getDeclaredField("blindedGraphSignature");
			blindedGraphSignatureField.setAccessible(true);

			GSSignature gs = (GSSignature) getValueOfField("graphSignature");
			GSSignature blindedGS = gs.blind();
			blindedGraphSignatureField.set(this, blindedGS);

			// execute storeBlindedGS method
			Method storeBlindedGSMethod = superClass.getDeclaredMethod("storeBlindedGS");
			storeBlindedGSMethod.setAccessible(true);
			storeBlindedGSMethod.invoke(this);

			// execute computeTildeZ method
			Method computeTildeZMethod = superClass.getDeclaredMethod("computeTildeZ");
			computeTildeZMethod.setAccessible(true);
			computeTildeZMethod.invoke(this);

		} catch (NoSuchFieldException | IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
			e.printStackTrace();
		}
	}


	public void executeCompoundPreChallengePhaseForPairWiseProver() {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();
		try {
			// get required fields for blinded graph signature
			Field blindedGraphSignatureField = superClass.getDeclaredField("blindedGraphSignature");
			blindedGraphSignatureField.setAccessible(true);

			GSSignature gs = (GSSignature) getValueOfField("graphSignature");
			GSSignature blindedGS = gs.blind();
			blindedGraphSignatureField.set(this, blindedGS);

			// execute storeBlindedGS method
			Method storeBlindedGSMethod = superClass.getDeclaredMethod("storeBlindedGS");
			storeBlindedGSMethod.setAccessible(true);
			storeBlindedGSMethod.invoke(this);

			// execute computeTildeZ method
			Method computeTildeZMethod = superClass.getDeclaredMethod("computeTildeZ");
			computeTildeZMethod.setAccessible(true);
			computeTildeZMethod.invoke(this);

			// execute computeCommitmentProvers method
			Method computeCommitmentProversMethod = superClass.getDeclaredMethod("computeCommitmentProvers");
			computeCommitmentProversMethod.setAccessible(true);
			computeCommitmentProversMethod.invoke(this);

			pairWiseDifferenceProvers = (List<PairWiseDifferenceProver>) getValueOfField("pairWiseDifferenceProvers");

		} catch (NoSuchFieldException | IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
			e.printStackTrace();
		}
	}

	public void computePairWiseProvers(List<PairWiseDifferenceProver> pairWiseDifferenceProvers) {

		for (PairWiseDifferenceProver differenceProver : pairWiseDifferenceProvers) {

			try {
				differenceProver.executeCompoundPreChallengePhase();
			} catch (ProofStoreException e) {
				gslog.log(Level.SEVERE, "Could not access the ProofStore.", e);
				return;
			}

		}
	}

	public List<PairWiseDifferenceProver> getPairWiseDifferenceProvers() {
		return pairWiseDifferenceProvers;
	}

	public List<CommitmentProver> getCommitmentProverList() {
		return commitmentProverList;
	}

	public void createCommitmentProvers() throws ProofStoreException, NoSuchFieldException, IllegalAccessException {
		CommitmentProver commitmentProver;
		commitmentProverList = new ArrayList<>();

		BaseCollection baseCollection = (BaseCollection) getValueOfField("baseCollection");
		Map<URN, GSCommitment> commitments = (Map<URN, GSCommitment>) getValueOfField("commitments");
		ExtendedPublicKey extendedPublicKey = (ExtendedPublicKey) getValueOfField("extendedPublicKey");
		ProofStore<Object> proofStore = (ProofStore<Object>) getValueOfField("proofStore");

		vertexIterator = baseCollection.createIterator(BaseRepresentation.BASE.VERTEX);

		for (BaseRepresentation vertex : vertexIterator) {
			String commURN = "prover.commitments.C_i_" + vertex.getBaseIndex();
			GSCommitment com = commitments.get(URN.createZkpgsURN(commURN));
			Assert.notNull(com, "Commitment submitted to CommitmentProver must not be null.");

			commitmentProver = new CommitmentProver(com, vertex.getBaseIndex(), extendedPublicKey.getPublicKey(), proofStore);

//			GroupElement tildeCommitment = commitmentProver.executePreChallengePhase();

			commitmentProverList.add(commitmentProver);

//			String tildeC_iURN = "commitmentprover.commitments.tildeC_i_" + vertex.getBaseIndex();
//
//			try {
//				proofStore.store(tildeC_iURN, tildeCommitment);
//			} catch (ProofStoreException e) {
//				gslog.log(Level.SEVERE, e.getMessage());
//			}
		}
	}

	public GroupElement computeCommitmentProvers() throws ProofStoreException {

		for (CommitmentProver commitmentProver : commitmentProverList) {
			tildeCommitment = commitmentProver.executePreChallengePhase();
		}

		return tildeCommitment;

	}

	Map<URN, BigInteger> responses;

	public void postChallengePhaseForCommitmentProver(BigInteger cChallenge) throws NoSuchFieldException, IllegalAccessException {

		PossessionProver possessionProver = (PossessionProver) getValueOfField("possessionProver");
		commitmentProverList = (List<CommitmentProver>) getValueOfField("commitmentProverList");
		try {
			responses = possessionProver.executePostChallengePhase(cChallenge);
		} catch (ProofStoreException e1) {
			gslog.log(Level.SEVERE, "Could not access the ProofStore.", e1);
			return;
		}


	}

	public Map<URN, BigInteger> executePostChallengePhaseForCommitmentProvers(BigInteger cChallenge) {

		Map<URN, BigInteger> response = new HashMap<>();
		for (CommitmentProver commitmentProver : commitmentProverList) {
			try {
				response = commitmentProver.executePostChallengePhase(cChallenge);
			} catch (ProofStoreException e) {
				gslog.log(Level.SEVERE, "Could not access the ProofStore.", e);
			}

			responses.putAll(response);
		}
		return responses;
	}

	public void postChallengePhaseForPairWiseProver(BigInteger cChallenge) throws NoSuchFieldException, IllegalAccessException {
		PossessionProver possessionProver = (PossessionProver) getValueOfField("possessionProver");
		commitmentProverList = (List<CommitmentProver>) getValueOfField("commitmentProverList");
		try {
			responses = possessionProver.executePostChallengePhase(cChallenge);
		} catch (ProofStoreException e1) {
			gslog.log(Level.SEVERE, "Could not access the ProofStore.", e1);
			return;
		}

		commitmentProverList = (List<CommitmentProver>) getValueOfField("commitmentProverList");
		Map<URN, BigInteger> response;
		for (CommitmentProver commitmentProver : commitmentProverList) {
			try {
				response = commitmentProver.executePostChallengePhase(cChallenge);
			} catch (ProofStoreException e) {
				gslog.log(Level.SEVERE, "Could not access the ProofStore.", e);
				return;
			}

			responses.putAll(response);
		}

		pairWiseDifferenceProvers = (List<PairWiseDifferenceProver>) getValueOfField("pairWiseDifferenceProvers");

	}

	public Map<URN, BigInteger> executePostChallengePhaseForPairWiseProvers(BigInteger cChallenge) {

		Map<URN, BigInteger> response = null;
		for (PairWiseDifferenceProver pwProver : pairWiseDifferenceProvers) {

			try {
				response = pwProver.executePostChallengePhase(cChallenge);
			} catch (ProofStoreException e) {
				gslog.log(Level.SEVERE, "Could not access the ProofStore.", e);
			}
		}
		return response;
	}

	private Object getValueOfField(String fieldName) throws NoSuchFieldException, IllegalAccessException {
		Class cl = this.getClass();
		Class superClass = cl.getSuperclass();
		Field proverOrchestratorField = superClass.getDeclaredField(fieldName);
		proverOrchestratorField.setAccessible(true);

		return proverOrchestratorField.get(this);
	}

	public void executePostChallengePhaseForPossessionProver(BigInteger cChallenge) throws IOException {

	}
}
