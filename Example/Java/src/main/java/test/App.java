package test;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

/**
 * Test
 */
public final class App {
    private App() {
        
    }

    /**
     * Main.
     * @param args The arguments of the program.
     */
    public static void main(String[] args) {
        ZContext context = new ZContext();
        ZMQ.Socket subscriber = context.createSocket(SocketType.SUB);

        Boolean enabled = true;
        String serverAddr = "tcp://localhost:5559";

        subscriber.connect(serverAddr);
        subscriber.subscribe("");

        while (enabled) {
            String messageReceived = subscriber.recvStr(0).trim();
            String[] messageData = messageReceived.split(" ");

            if (messageData.length != 2)
                continue;

            String[] quoteData = messageData[1].toString().split("\\|");

            if (quoteData.length != 4)
                continue;

            System.out.println("Login: " + messageData[0] + ", Symbol: " + quoteData[0] + ", Ask: " + quoteData[1] + ", Bid: " + quoteData[2] + ", Spread: " + quoteData[3]);
        }

        subscriber.disconnect(serverAddr);
        subscriber.close();

        context.close();
    }
}
