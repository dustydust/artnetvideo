
import java.net.SocketException;
import java.util.List;

import java.awt.image.BufferedImage;

import artnet4j.ArtNet;
import artnet4j.ArtNetException;
import artnet4j.ArtNetNode;
import artnet4j.events.ArtNetDiscoveryListener;
import artnet4j.packets.ArtDmxPacket;

import gifAnimation.*;

int frameIndex;
int sequenceID;

GifDecoder d = new GifDecoder();

ArtNet artnet;

void setup() {
  d.read("/Users/Micael/Desktop/artnetvideo/cat.gif");

  try {
    artnet = new ArtNet();
    artnet.setReceivePort(6453);
    artnet.setSendPort(6454);
    artnet.start();
    artnet.setBroadCastAddress("192.168.1.255");

    Thread.sleep(30);
  } catch (SocketException e) {
      e.printStackTrace();
  } catch (ArtNetException e) {
      e.printStackTrace();
  } catch (InterruptedException e) {
      e.printStackTrace();
  }

}

void draw() {

  int n = d.getFrameCount();

  //println("draw " + n + " frames");


  for (int i = 0; i < n; i++) {
    BufferedImage frame = d.getFrame(i);  // frame i
    int gifFrameDelay = d.getDelay(i);  // display duration of frame in milliseconds
    int frameWidth = frame.getWidth();
    int frameHeight = frame.getHeight();
    
    //println("frameWidth = " + frameWidth + ", frameHeight = " + frameHeight);
    
    int channelsTotal = frameWidth * frameHeight * 3;
    int universesTotal = ceil((float) channelsTotal / 512);
    //println("universesTotal = " + universesTotal);
    
    byte[] channelsData = new byte[channelsTotal + 512];
    
    for (int y = 0; y < frameHeight; y++) {
      for (int x = 0; x < frameWidth; x++) {
        int channelIndex = (x + y * frameWidth) * 3;
        int pixel = frame.getRGB(x, y);
        //println(hex(pixel, 6));
        //delay(100);
        //color pixelColor = color(pixel);
        channelsData[channelIndex + 0] = (byte) red(pixel);
        channelsData[channelIndex + 1] = (byte) green(pixel);
        channelsData[channelIndex + 2] = (byte) blue(pixel);
        //println(channelsData[channelIndex + 0]);
        //println(channelsData[channelIndex + 1]);
        //println(channelsData[channelIndex + 2]);
        //delay(10);
        //color pixelColor = color(frame.getRGB(x, y));
        //channelsData[channelIndex + 0] = (byte) red(pixelColor);
        //channelsData[channelIndex + 1] = (byte) green(pixelColor);
        //channelsData[channelIndex + 2] = (byte) blue(pixelColor);
      }
    }

    for (int universeCounter = 0; universeCounter < universesTotal; universeCounter++) {
      int subnet = floor((float)(universeCounter / 16));
      //int network = floor((float)(subnet / 16));
      int universe = universeCounter % 16;

      ArtDmxPacket dmxPacket = new ArtDmxPacket(); //<>//
      byte[] buffer = new byte[512];
      int channelOffset = universeCounter * 512;
      
      //println("channelOffset = " + channelOffset);
      
      arrayCopy(channelsData, channelOffset, buffer, 0, 512);

      //println("Subnet: " + subnet + " Universe: " + universe);
      dmxPacket.setUniverse(subnet, universe);
      //dmxTest.setUniverseID(jj % 16);
      //dmxTest.setSubnetID(floor((float)(jj / 16)));
      
      dmxPacket.setDMX(buffer, buffer.length);
      //artnet.broadcastPacket(dmxPacket);

      //artnet.unicastPacket(dmxPacket, "192.168.1.66"); // 192.168.1.68 10.211.55.5
      //artnet.unicastPacket(dmxPacket, "192.168.1.67"); // 192.168.1.68 10.211.55.5
      //artnet.unicastPacket(dmxPacket, "192.168.1.68");
      //artnet.unicastPacket(dmxPacket, "192.168.1.69");
      artnet.unicastPacket(dmxPacket, "127.0.0.1");
      //artnet.unicastPacket(dmxPacket, "10.211.55.5"); // 192.168.1.68 10.211.55.5
      delay(4); 
    }

    //println("SeqID " + sequenceID++);

    // Delay for next frame
    delay(gifFrameDelay);
  } 
}




class PollTest implements ArtNetDiscoveryListener {

    private ArtNetNode netLynx;

    //private int sequenceID;

    @Override
    public void discoveredNewNode(ArtNetNode node) {
        if (netLynx == null) {
            netLynx = node;
            System.out.println("found net lynx");
        }
    }

    @Override
    public void discoveredNodeDisconnected(ArtNetNode node) {
        System.out.println("node disconnected: " + node);
        if (node == netLynx) {
            netLynx = null;
        }
    }

    @Override
    public void discoveryCompleted(List<ArtNetNode> nodes) {
        System.out.println(nodes.size() + " nodes found:");
        for (ArtNetNode n : nodes) {
            System.out.println(n);
        }
    }

    @Override
    public void discoveryFailed(Throwable t) {
        System.out.println("discovery failed");
    }

    private void test() {

        //ArtNet artnet = new ArtNet();
        //artnet.setReceivePort(6453);
        //artnet.setSendPort(6454);
        int index = 0;
        
        //int MATRIX_COUNT = 1; 

        try {
            artnet.start();
            //artnet.getNodeDiscovery().addListener(this);
            //artnet.startNodeDiscovery();
            while (true) {
              
              ArtDmxPacket dmxTest = new ArtDmxPacket();
              byte[] bufferTest = new byte[512];
              
              for (int i = 0; i < 512; i++) {
                
                //bufferTest[i] = (byte) 255;
                
                  // Normal Sin Sequence
//                  byte value = (byte) (Math.sin(sequenceID * 0.05 + i * 0.8) * 127 + 128);
//                  bufferTest[i] = value;
                  
                  // Add Tan Sequence
//                  byte value = (byte) (Math.tan(sequenceID * 0.05 + i * 0.8));
//                  bufferTest[i] = value;
                  
                  // Noise Sequence
                  //byte value = (byte) (Math.sin(sequenceID * 0.65 + i * 0.8) * 127 * 128);
                  //bufferTest[i] = value;
                  
                  // Dot test
                  index = (int) sequenceID % 512; // dot
                  bufferTest[i] = (byte) (i == index ? 255 : 0);
              }
              
              // Tessel and local send data
              // int un_count = ceil((float)(MATRIX_COUNT * 256 * 3) / 512);
              int un_count = ceil((float)(200 * 200 * 3) / 512);
              //println(un_count);
              for (int jj = 0; jj < un_count; jj++) {
                int subnet = floor((float)(jj / 16));
                //int network = floor((float)(subnet / 16));
                int universe = jj % 16;
                
                //println("Subnet: " + subnet + " Universe: " + universe);
               
                
                dmxTest.setUniverse(subnet, universe);
                
                //dmxTest.setUniverseID(jj % 16);
                //dmxTest.setSubnetID(floor((float)(jj / 16)));
                
                dmxTest.setDMX(bufferTest, bufferTest.length);
                artnet.unicastPacket(dmxTest, "192.168.1.66"); // 192.168.1.68 10.211.55.5
               
                //artnet.unicastPacket(dmxTest, "10.211.55.5"); // 192.168.1.68 10.211.55.5
                delay(1); 
              }
              println("SeqID " + sequenceID);
              // Local send data
              //dmxTest.setUniverse(0, 0);
              //dmxTest.setDMX(bufferTest, bufferTest.length);
              //artnet.unicastPacket(dmxTest, "127.0.0.1");
              
              
              sequenceID++;
              
                if (netLynx != null) {
                    ArtDmxPacket dmx = new ArtDmxPacket();
                    dmx.setUniverse(netLynx.getSubNet(), netLynx.getDmxOuts()[0]);
                    dmx.setSequenceID(sequenceID % 255);
                    byte[] buffer = new byte[510];
                    buffer[0] = (byte) 55;
                    for (int i = 0; i < buffer.length; i++) {
                        buffer[i] = (byte) (Math.sin(sequenceID * 0.05 + i * 0.8) * 127 + 128);
                    }
                    dmx.setDMX(buffer, buffer.length);
                    artnet.unicastPacket(dmx, netLynx.getIPAddress());
                    dmx.setUniverse(netLynx.getSubNet(), netLynx.getDmxOuts()[1]);
                    artnet.unicastPacket(dmx, netLynx.getIPAddress());
                    sequenceID++;
                }
                Thread.sleep(30);
            }
        } catch (SocketException e) {
            e.printStackTrace();
        } catch (ArtNetException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

//
//final static int NUM_CHANNELS_DISPLAYED = 6; 
//
//ArtNetListener artNetListener;
//byte[] inputDmxArray;
//
//void setup() {
//  size( 800, 250);
//  if( frame != null) { frame.setResizable( true); }
//  textSize( 16);
//
//  println( "Starting ...");
//  artNetListener = new ArtNetListener();
//}
//
//void exit() {
//  println( "Exiting ...");
//  artNetListener.stopArtNet();
//  super.exit();
//}
//
//void draw() {
//  background( 0);
//  inputDmxArray = artNetListener.getCurrentInputDmxArray(); 
//  displayDMXInput();
//  displayStatus();
//}
//
//void displayDMXInput() {
//  float barH, barW;
//
//  stroke( 32, 192);
//  fill( 128, 192);
//
//  barW = float( width - 41) / NUM_CHANNELS_DISPLAYED;
//  for( int i = 0; i < NUM_CHANNELS_DISPLAYED; i++) {
//    barH = floor( map( artNetListener.toInt( inputDmxArray[ i]),
//                  0, 255, 0, height - 40));
//    rect( 19 + barW * i, height - 20 - barH, barW, barH);
//  }
//}
//
//void displayStatus() {
//  fill( 255);
//  text( inputDmxArray.length + " DMX channels, " + NUM_CHANNELS_DISPLAYED + " displayed\n"
//        + width + " x " + height + "px (" + str( int( frameRate)) + " fps)"
//        , 50, 50);
//}