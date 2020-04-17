// Bakeoff #2 - Seleção de Alvos e Fatores Humanos //<>// //<>//
// IPM 2019-20, Semestre 2
// Bake-off: durante a aula de lab da semana de 20 de Abril
// Submissão via Twitter: exclusivamente no dia 24 de Abril, até às 23h59

// Processing reference: https://processing.org/reference/

import java.util.Collections;

// Target properties
float PPI, PPCM;
float SCALE_FACTOR;
float TARGET_SIZE;
float TARGET_PADDING, MARGIN, LEFT_PADDING, TOP_PADDING;

// Study properties
ArrayList<Integer> trials  = new ArrayList<Integer>();    // contains the order of targets that activate in the test
ArrayList<Float> performance = new ArrayList<Float>();
int trialNum               = 0;                           // the current trial number (indexes into trials array above)
final int NUM_REPEATS      = 3;                           // sets the number of times each target repeats in the test - FOR THE BAKEOFF NEEDS TO BE 3!
boolean ended              = false;

// Performance variables
int startTime              = 0;      // time starts when the first click is captured
int finishTime             = 0;      // records the time of the final click
int hits                   = 0;      // number of successful clicks
int misses                 = 0;      // number of missed clicks

// Class used to store properties of a target
class Target
{
  int x, y;
  float w;

  Target(int posx, int posy, float twidth) 
  {
    x = posx;
    y = posy;
    w = twidth;
  }
}


// Setup window and vars - runs once
void setup()
{
  //size(900, 900);              // window size in px (use for debugging)
  fullScreen();                // USE THIS DURING THE BAKEOFF!
  
  SCALE_FACTOR    = 1.0 / displayDensity();            // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");        // The text from the file is loaded into an array.
  PPI            = float(ppi_string[1]);               // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM           = PPI / 2.54 * SCALE_FACTOR;          // do not change this!
  TARGET_SIZE    = 1.5 * PPCM;                         // set the target size in cm; do not change this!
  TARGET_PADDING = 1.5 * PPCM;                         // set the padding around the targets in cm; do not change this!
  MARGIN         = 1.5 * PPCM;                         // set the margin around the targets in cm; do not change this!
  LEFT_PADDING   = width/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;        // set the margin of the grid of targets to the left of the canvas; do not change this!
  TOP_PADDING    = height/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;       // set the margin of the grid of targets to the top of the canvas; do not change this!
  
  noStroke();        // draw shapes without outlines
  frameRate(60);     // set frame rate

  // Text and font setup
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  textAlign(CENTER);                    // align text
  
  randomizeTrials();    // randomize the trial order for each participant
}

// Updates UI - this method is constantly being called and drawing targets
void draw()
{
  if (hasEnded()) return; // nothing else to do; study is over

  background(0);       // set background to black

  // Print trial count
  fill(255);          // set text fill color to white
  text("Trial " + (trialNum + 1) + " of " + trials.size(), 50, 20);    // display what trial the participant is on (the top-left corner)

  // Draw targets
  for (int i = 0; i < 16; i++) {
    
    drawTarget(i);
  }
}

boolean hasEnded() {
  if (ended) return true;    // returns if test has ended before

  // Check if the study is over
  if (trialNum >= trials.size())
  {
    float timeTaken = (finishTime-startTime) / 1000f;     // convert to seconds - DO NOT CHANGE!
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f), 0, 100);    // calculate penalty - DO NOT CHANGE!

    printResults(timeTaken, penalty);    // prints study results on-screen
    ended = true;
  }

  return ended;
}

// Randomize the order in the targets to be selected
// DO NOT CHANGE THIS METHOD!
void randomizeTrials()
{
  for (int i = 0; i < 16; i++)             // 4 rows times 4 columns = 16 target
    for (int k = 0; k < NUM_REPEATS; k++)  // each target will repeat 'NUM_REPEATS' times
      trials.add(i);
  Collections.shuffle(trials);             // randomize the trial order

  System.out.println("trial order: " + trials);    // prints trial order - for debug purposes
}

// Print results at the end of the study
void printResults(float timeTaken, float penalty)
{
  background(0);       // clears screen

  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen

  text("Finished!", width / 2, 40); 
  text("Hits: " + hits, width / 2, 60);
  text("Misses: " + misses, width / 2, 80);
  text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, 100);
  text("Total time taken: " + timeTaken + " sec", width / 2, 120);
  text("Average time for each target: " + nf((timeTaken)/(float)(hits+misses), 0, 3) + " sec", width / 2, 140);
  text("Average time for each target + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty), 0, 3) + " sec", width / 2, 180);
  text("Fitts Index of Performance", width / 2, 220);
  text("Target 1: ---", width / 2 - 100, 240);  
  
  for (int i = 1; i < 24; i++) {
    if (performance.get(i) == 0.0) text("Target " + (i + 1) + ": " + "MISSED", width / 2 - 100, 240 + 20*i);
    else text("Target " + (i + 1) + ": " + performance.get(i), width / 2 - 100, 240 + 20*i);
      
}
  for (int i = 1; i < 24; i++) {
    if (performance.get(i + 24) == 0.0) text("Target " + (i + 24) + ": " + "MISSED", width / 2 + 100, 240 + 20*i);
    else text("Target " + (i + 24) + ": " + performance.get(i + 24), width / 2 + 100, 240 + 20*i); 
  }

  saveFrame("results-######.png");    // saves screenshot in current folder
}

// Mouse button was released - lets test to see if hit was in the correct target
void mouseReleased() 
{
  if (trialNum >= trials.size()) return;      // if study is over, just return
  if (trialNum == 0) startTime = millis();    // check if first click, if so, start timer
  if (trialNum == trials.size() - 1)          // check if final click
  {
    finishTime = millis();    // save final timestamp
    println("We're done!");
  }

  Target target = getTargetBounds(trials.get(trialNum));    // get the location and size for the target in the current trial

  // Check to see if mouse cursor is inside the target bounds
  if (dist(target.x, target.y, mouseX, mouseY) < target.w/2)
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime));     // success - hit!
    hits++; // increases hits counter
    float aux = Mackenzie(trialNum);
    performance.add(aux);
  } else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime));  // fail
    misses++;   // increases misses counter
    performance.add(0.0);
  }
  

  trialNum++;   // move on to the next trial; UI will be updated on the next draw() cycle
}  

// For a given target ID, returns its location and size
Target getTargetBounds(int i)
{
  int x = (int)LEFT_PADDING + (int)((i % 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  int y = (int)TOP_PADDING + (int)((i / 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);

  return new Target(x, y, TARGET_SIZE);
}

// Draw target on-screen
// This method is called in every draw cycle; you can update the target's UI here
void drawTarget(int i)
{
  Target target = getTargetBounds(i);   // get the location and size for the circle with ID:i

  // check whether current circle is the intended target
  if (trials.get(trialNum) == i) 
  { 
    // if so ...
    stroke(#ffffff);
    strokeWeight(10);
    fill(#3232ff);       // fill orange

  }
  // check whether current circle is the next target
  else if (trialNum < 47 && trials.get(trialNum+1) == i) 
  { 
    // if so ...
    //stroke(220, 130, 20);       // stroke orange
    //strokeWeight(4);   // stroke weight 7
    fill(#adadff);
  }
  else
    fill(155);           // fill dark gray
  alpha(100);
  circle(target.x, target.y, target.w);   // draw target

  noStroke();    // next targets won't have stroke (unless it is the intended target)
}



/*
// Draw target on-screen
// This method is called in every draw cycle; you can update the target's UI here
void drawTarget(int i)
{
  Target target = getTargetBounds(i);   // get the location and size for the circle with ID:i

  // check whether current circle is the intended target
  if (trials.get(trialNum) == i) 
  { 
    // if so ...
    stroke(220);       // stroke light gray
    strokeWeight(2);   // stroke weight 2
  }

  fill(155);           // fill dark gray
  alpha(100);
  circle(target.x, target.y, target.w);   // draw target

  noStroke();    // next targets won't have stroke (unless it is the intended target)
}
*/


float Mackenzie(int i) {
  Target target1 = getTargetBounds(i);
  Target target2 = getTargetBounds(i - 1);
  
  int x1 = target1.x;
  int y1 = target1.y;
   
  int x2 = target2.x;
  int y2 = target2.y;
  
  float distTarget = dist(x1, y1, x2, y2);
  float TargetSize = 1.5 * PPCM;
   
  float res = (log(2) * ((distTarget / (TargetSize + 1))));
  
  return res;

}