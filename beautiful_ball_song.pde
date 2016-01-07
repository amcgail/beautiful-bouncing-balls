import javax.sound.midi.*;
import java.util.ArrayList;
import java.util.List;
import java.io.*;

Synthesizer synth;

int channel = 0; // 0 is a piano, 9 is percussion, other channels are for other instruments

int volume = 80; // between 0 et 127
int duration = 200; // in milliseconds

MidiChannel[] channels;

List<Ball> balls = new ArrayList<Ball>();

Ball bigball;

int[] scale = {
  0, 4, 9, 11,
  12+0, 12+4, 12+7, 12+9, 12+11,
  24+0, 24+2, 24+4, 24+5, 24+7, 24+9, 24+11
};

int bg = 1;
int dir = 1;

int notemillis = -1;

void setup() {
  this.randomSeed( 5 );
  
  balls.add( new Ball(100, 400, 20) );
  
  size(700, 550);

  try {
    synth = MidiSystem.getSynthesizer();
    synth.open();
    channels = synth.getChannels();
  } catch(Exception e) {
    e.printStackTrace();
  }
}

int f = 0;

void draw() {
  f += 1;
  if( millis() / 5000 > balls.size() && millis() < 60000 && millis() < 120000 ) {
     balls.add( new Ball(100, 400, 20) );
  }
  
  if( millis() > 120000 && balls.size() == 11 && millis() < 160000 ) {
    bigball = new Ball( 350, 350, 60 );
    balls.add( bigball );
  }
    
  if( millis() > 160000 && balls.size() > 11 - (millis() - 160000)/5000 ) {
    balls.remove( 0 );
  }
  
  if( bg >= 255*4 || bg <= 0 )
    dir *= -1;
  bg += dir;    
  background((bg+dir)/4);

  int i=0;
  for (Ball b : balls) {
    i++;
    
    b.update();
    b.display();
    if( b.checkBoundaryCollision() ) {
      channels[channel].noteOn( 60-12+scale[i%10], volume/2 ); // C note
      notemillis = millis();    
    };
  }
  
  i=0;
  for (Ball b1: balls) {
    for (Ball b2: balls) {
      if( b1 == b2 ) continue;
      i++;
      
      if( b1.checkCollision(b2) ) {
         b1.c = 0;
         b2.c = 0;
         if( b1 == bigball || b2 == bigball ) {
           channels[channel].noteOn( 60+7+12+(i%3)*2, volume-10 );
         } else {
          channels[channel].noteOn( 60-24+scale[i%10], volume ); // C note
          notemillis = millis();
         }
      }
    }
  }
  
  if( notemillis > 0 && millis() - notemillis > 1000 ) {
    channels[channel].allNotesOff();
    notemillis = -1;
  }
  //saveFrame("frames####.png");
}