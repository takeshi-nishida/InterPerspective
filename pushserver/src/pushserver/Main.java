/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package pushserver;

import net.PolicyFileServer;

/**
 *
 * @author tnishida
 */
public class Main{
  private static final int DEFAULT_PORT = 15001;

  /**
   * @param args the command line arguments
   */
  public static void main(String[] args){
    int port;

    try{
      port = Integer.parseInt(args[0]);
    } catch(Exception e){
      port = DEFAULT_PORT;
    }
    
    //PolicyFileServer.start(843, DEFAULT_PORT);

    System.out.println("Starting push server at port: " + port);
    Server server = new Server(port);
    Thread t = new Thread(server);
    t.start();
  }
}
