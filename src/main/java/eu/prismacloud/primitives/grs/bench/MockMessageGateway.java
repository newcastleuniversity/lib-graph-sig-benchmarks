package eu.prismacloud.primitives.grs.bench;

import eu.prismacloud.primitives.zkpgs.message.GSMessage;
import eu.prismacloud.primitives.zkpgs.message.IMessageGateway;
import eu.prismacloud.primitives.zkpgs.store.URN;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;

/**
 * Mock gateway proxy for testing orchestrator
 */
public class MockMessageGateway implements IMessageGateway {
	private Deque<GSMessage> messageList = new ArrayDeque<>();
	private GSMessage temp;

	public MockMessageGateway(String type, String hostAddress, Integer portNumber) {
	}

	@Override
	public void init() throws IOException {
//		gslog.info("init");

	}

	@Override
	public void send(GSMessage message) throws IOException {
//		gslog.info("send message: " + message.getMessageElements() + "\n");

		temp = new GSMessage();
		if (message.getMessageElements().get(URN.createUnsafeZkpgsURN("proof.request")) != null && !messageList.contains(temp)) {
			messageList.addFirst(message);
		}

		if (message.getMessageElements().size() >= 1) {
			messageList.addFirst(message);
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
