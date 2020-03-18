package pushserver;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import net.StringListener;
import net.StringSession;
import util.BiMap;

/**
 * protocol
 * server: send "ClientIDs >> Body"
 * client: send "#ClientID" to login
 */
public class Server implements Runnable, StringListener{
  private static final String CLIENT_PREFIX = "#";
  private static final String SEPARATOR = " ";
  private static final String END_OF_HEADER = " >> ";
  private int port;
  private final BiMap<Integer, StringSession> clients;

  public Server(int port){
    this.port = port;
    clients = new BiMap<Integer, StringSession>();
  }

  public void run(){
    try{
      ServerSocket ss = new ServerSocket(port);

      while(true){
        Socket socket = ss.accept();
        StringSession session = new StringSession(this, socket);
        session.setCharsetName("UTF-8");
        session.startup();
      }
    } catch(IOException ex){
    }
  }

  public void received(StringSession session, String s){
    synchronized(clients){
      if(s.startsWith(CLIENT_PREFIX)){ // add to clients
        int id = Integer.parseInt(s.substring(CLIENT_PREFIX.length()));
        clients.put(id, session);
      } else{ // push data to clients
        String[] array = s.split(END_OF_HEADER, 2); // "ClientIDs END_OF_HEADER Body"
        if(array.length == 2){
          for(String idString : array[0].split(SEPARATOR)){
            StringSession client = clients.get(Integer.parseInt(idString));
            if(client != null){
              client.sendln(array[1]);
            }
          }
        }
      }
    }
  }

  public void cleaned(StringSession session, boolean abnormally){
    synchronized(clients){
      clients.removeValue(session);
    }
  }
}
