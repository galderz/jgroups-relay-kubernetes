package demo;

import org.jgroups.Address;
import org.jgroups.JChannel;
import org.jgroups.Message;
import org.jgroups.ReceiverAdapter;
import org.jgroups.View;
import org.jgroups.protocols.relay.RELAY2;
import org.jgroups.protocols.relay.RouteStatusListener;
import org.jgroups.util.Util;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class Demo
{
    public static void main(String[] args) throws Exception
    {
        final String siteName = System.getenv("SITE_NAME");
        System.out.println("Hello world! (" + siteName + ")");

        String props = String.format("local-Site%s.xml", siteName);
        //String name = "relay-channel";

        final JChannel channel = new JChannel(props);
        //channel.setName(name);

        channel.setReceiver(new ReceiverAdapter()
        {
            public void receive(Message msg)
            {
                Address sender = msg.getSrc();
                System.out.println("<< " + msg.getObject() + " from " + sender);
                Address dst = msg.getDest();
                if (dst == null)
                {
                    Message rsp = new Message(msg.getSrc(), "this is a response");
                    try
                    {
                        channel.send(rsp);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                }
            }

            public void viewAccepted(View new_view)
            {
                System.out.println(print(new_view));
            }
        });

        RELAY2 relay = channel.getProtocolStack().findProtocol(RELAY2.class);
        relay.setRouteStatusListener(new RouteStatusListener()
        {
            final Set<String> sitesView = new HashSet<>();

            public void sitesUp(String... sites)
            {
                updateSitesView(Arrays.asList(sites), Collections.emptyList());
//                Set<String> reachableSites = new HashSet<>(sitesView);
//                reachableSites.addAll(sitesUp);
//                reachableSites.removeAll(sitesDown);
//
//                System.out.printf("-- %s: site(s) %s came up\n",
//                    channel.getAddress(), String.join(", ", sites));
            }

            public void sitesDown(String... sites)
            {
                updateSitesView(Collections.emptyList(), Arrays.asList(sites));
//                System.out.printf("-- %s: site(s) %s went down\n",
//                    channel.getAddress(), String.join(", ", sites));
            }

            private void updateSitesView(Collection<String> sitesUp, Collection<String> sitesDown) {
                Set<String> reachableSites = new HashSet<>(sitesView);
                reachableSites.addAll(sitesUp);
                reachableSites.removeAll(sitesDown);
                System.out.printf("Received new x-site view: %s%n", reachableSites);
                sitesView.clear();
                sitesView.addAll(reachableSites);
            }
        });

        channel.connect("RelayDemo");

        while (!Thread.currentThread().isInterrupted()) {
            Thread.sleep(1000);
        }

        for (; ; )
        {
            String line = Util.readStringFromStdin(": ");
            channel.send(null, line);
        }
    }

    private static String print(View view)
    {
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        sb.append(view.getClass().getSimpleName()).append(": ").append(view.getViewId()).append(": ");
        for (Address mbr : view.getMembers())
        {
            if (first)
                first = false;
            else
                sb.append(", ");
            sb.append(mbr);
        }
        return sb.toString();
    }

}
