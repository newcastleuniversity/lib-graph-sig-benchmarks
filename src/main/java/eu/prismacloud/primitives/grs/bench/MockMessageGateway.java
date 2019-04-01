package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.BaseRepresentation;
import eu.prismacloud.primitives.zkpgs.commitment.GSCommitment;
import eu.prismacloud.primitives.zkpgs.graph.GraphRepresentation;
import eu.prismacloud.primitives.zkpgs.keys.ExtendedPublicKey;
import eu.prismacloud.primitives.zkpgs.message.GSMessage;
import eu.prismacloud.primitives.zkpgs.message.IMessageGateway;
import eu.prismacloud.primitives.zkpgs.orchestrator.PairWiseCommitments;
import eu.prismacloud.primitives.zkpgs.prover.ProofSignature;
import eu.prismacloud.primitives.zkpgs.store.URN;
import eu.prismacloud.primitives.zkpgs.util.BaseCollection;
import eu.prismacloud.primitives.zkpgs.util.BaseCollectionImpl;
import eu.prismacloud.primitives.zkpgs.util.BaseIterator;
import eu.prismacloud.primitives.zkpgs.util.FilePersistenceUtil;
import eu.prismacloud.primitives.zkpgs.util.crypto.GroupElement;
import eu.prismacloud.primitives.zkpgs.util.crypto.QRElement;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.math.BigInteger;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Mock gateway proxy for testing orchestrator
 */
public class MockMessageGateway implements IMessageGateway {
	private Deque<GSMessage> messageList = new ArrayDeque<>();
	private GSMessage temp;
	private FilePersistenceUtil persistenceUtil = new FilePersistenceUtil();
	private int i = 0;
	private PrintStream out;

	public MockMessageGateway(String type, String hostAddress, Integer portNumber) {
	}

	@Override
	public void init() throws IOException {
//		gslog.info("init");

	}

	@Override
	public void send(GSMessage message) throws IOException {
//		System.out.println("send message: " + message.getMessageElements() + "\n");

		Map<URN, Object> messageElements = message.getMessageElements();
		persistMessage(message);
		out = getPrintStream();
		printHeader();
		measureMessageBits(messageElements);

		temp = new GSMessage();

		if (message.getMessageElements().get(URN.createUnsafeZkpgsURN("proof.request")) != null && !messageList.contains(temp)) {
			messageList.addFirst(message);
		}

		if (message.getMessageElements().size() >= 1) {
			messageList.addFirst(message);
		}

	}

	static String messageNo = "";

	private void persistMessage(GSMessage message) throws IOException {
		i++;
		System.out.println("------------ MESSAGE_" + i + " -------------- \n");
		messageNo = "message_" + i;
		Date date = new Date();
		Format formatter = new SimpleDateFormat("YYYY-MM-dd_hh-mm-ss");
		String fileName = messageNo + "-" + ((SimpleDateFormat) formatter).format(date);
		persistenceUtil.write(message,  fileName + ".ser");
	}

	private void measureMessageBits(Map<URN, Object> messageElements) {

		for (Map.Entry<URN, Object> entry : messageElements.entrySet()) {
			URN key = entry.getKey();
			Object value = entry.getValue();
			System.out.println("class name: " + value.getClass().getSimpleName() + "\n");
			String clName = value.getClass().getSimpleName();

			switch (clName) {
				case "HashMap":
					Map<URN, Object> hm = (HashMap<URN, Object>) value;
					measureMessageBits(hm);
					break;
				case "BigInteger":
					BigInteger bi = (BigInteger) value;
//					System.out.println(key.toHumanReadableString() + " bitlength:  " + bi.bitLength() + "\n");
					printLine(key.toHumanReadableString(), clName, String.valueOf(bi.bitLength()));
					break;
				case "QRElement":
					QRElement qe = (QRElement) value;
//					System.out.println( key.toHumanReadableString() + " bitlength:  " + qe.bitLength() + "\n");
					printLine(key.toHumanReadableString(), clName, String.valueOf(qe.bitLength()));
					break;
				case "GSCommitment":
					GSCommitment com = (GSCommitment) value;
//					System.out.println( key.toHumanReadableString() + " bitlength:  " + com.getCommitmentValue().bitLength() + "\n");

					printLine(key.toHumanReadableString(), com.getCommitmentValue().getClass().getSimpleName(), String.valueOf(com.getCommitmentValue().bitLength()));
					break;
				case "ProofSignature":
					ProofSignature proof = (ProofSignature) value;
					Map<URN, Object> msg = proof.getProofSignatureElements();
					measureMessageBits(msg);
					break;
				case "GraphRepresentation":
					GraphRepresentation gr = (GraphRepresentation) value;
					BaseCollection bc = gr.getEncodedBaseCollection();
					measureBaseCollectionBits(bc);
					break;
				case "BaseCollectionImpl":
					BaseCollection bci = (BaseCollectionImpl) value;
					measureBaseCollectionBits(bci);
					break;
				case "PairWiseCommitments":
					PairWiseCommitments pwc = (PairWiseCommitments) value;
					GSCommitment gci = pwc.getC_i();
					printLine(key.toHumanReadableString(), gci.getCommitmentValue().getClass().getSimpleName(),  String.valueOf(gci.getCommitmentValue().bitLength()));
					GSCommitment gcj = pwc.getC_j();
					printLine(key.toHumanReadableString(),gcj.getCommitmentValue().getClass().getSimpleName(), String.valueOf(gcj.getCommitmentValue().bitLength()));
					break;
				case "ExtendedPublicKey":
					ExtendedPublicKey epk = (ExtendedPublicKey) value;

					GroupElement baseR = epk.getPublicKey().getBaseR();
//					System.out.println(key.toHumanReadableString() + " bitlength:  " + baseR.bitLength() + "\n");
					printLine(key.toHumanReadableString(), baseR.getClass().getSimpleName(), String.valueOf(baseR.bitLength()));
					GroupElement baseR_0 = epk.getPublicKey().getBaseR_0();
//					System.out.println(key.toHumanReadableString() + " bitlength:  " + baseR_0.bitLength() + "\n");
					printLine(key.toHumanReadableString(), baseR_0.getClass().getSimpleName(), String.valueOf(baseR_0.bitLength()));

					GroupElement baseS = epk.getPublicKey().getBaseS();
//					System.out.println(key.toHumanReadableString() + " bitlength:  " + baseS.bitLength() + "\n");
					printLine(key.toHumanReadableString(), baseS.getClass().getSimpleName(), String.valueOf(baseS.bitLength()));

					GroupElement baseZ = epk.getPublicKey().getBaseZ();
//					System.out.println(key.toHumanReadableString() + " bitlength:  " + baseZ.bitLength() + "\n");
					printLine(key.toHumanReadableString(), baseZ.getClass().getSimpleName(), String.valueOf(baseZ.bitLength()));
					break;
			}

		}
	}


	private final String delimiter = ",";

	private static PrintStream getPrintStream() throws FileNotFoundException {
		Date date = new Date();
		Format formatter = new SimpleDateFormat("YYYY-MM-dd_hh-mm-ss");
		return new PrintStream(new File(messageNo + "-" + ((SimpleDateFormat) formatter).format(date)) + ".csv");
	}

	private void printHeader() {
		out.print("\"URN\"");
		out.print(delimiter);
		out.print("\"ClassName\"");
		out.print(delimiter);
		out.print("\"Bitlength\"");
		out.print("\r\n");
	}

	private void printLine(String urnKey, String className,  String bitlength) {
		out.print("\"");
		out.print(urnKey);
		out.print("\"");
		out.print(delimiter);
		out.print("\"");
		out.print(className);
		out.print("\"");
		out.print(delimiter);
		out.print("\"");
		out.print(bitlength);
		out.print("\"");
		out.print("\r\n");
	}


	private void measureBaseCollectionBits(BaseCollection bases) {
		BaseIterator bIterator = bases.createIterator(BaseRepresentation.BASE.ALL);
		for (BaseRepresentation base : bIterator) {
//			base.getBase()
//			System.out.println(base.getBaseType() + " base index: " + base.getBaseIndex() + " group element bitcount: " + base.getBase().bitCount() + "\n");
//			System.out.println(base.getBaseType() + " base index: " + base.getBaseIndex() + " group element bitlength:  " + base.getBase().bitLength() + "\n");
			printLine(base.getBaseType() + String.valueOf(base.getBaseIndex()), base.getBase().getClass().getSimpleName(), String.valueOf(base.getBase().bitLength()));
//			System.out.println(base.getBaseType() + " base index: " + base.getBaseIndex() + " exponent bitcount: " + base.getExponent().bitCount() + "\n");
//			System.out.println(base.getBaseType() + " base index: " + base.getBaseIndex() + " exponent bitlength:  " + base.getExponent().bitLength() + "\n");
			printLine(base.getBaseType() + String.valueOf(base.getBaseIndex()), base.getExponent().getClass().getSimpleName(), String.valueOf(base.getExponent().bitLength()));
		}

	}

	@Override
	public GSMessage receive() throws IOException {
		GSMessage gsMessage = new GSMessage();

		if (messageList != null && !messageList.isEmpty()) {
//			System.out.println("contains: " + messageList.contains(temp));
			gsMessage = messageList.pollLast();
		}

		return gsMessage;
	}

	@Override
	public void close() throws IOException {
//		gslog.info("close connection");
	}
}
