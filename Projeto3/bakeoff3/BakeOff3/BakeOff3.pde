// Bakeoff #3 - Escrita de Texto em Smartwatches
// IPM 2019-20, Semestre 2
// Entrega: exclusivamente no dia 22 de Maio, até às 23h59, via Discord

// Processing reference: https://processing.org/reference/

import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import processing.sound.*;


// Screen resolution vars;
float PPI, PPCM;
float SCALE_FACTOR;

// Finger parameters
PImage fingerOcclusion;
int FINGER_SIZE;
int FINGER_OFFSET;

// Arm/watch parameters
PImage arm;
int ARM_LENGTH;
int ARM_HEIGHT;

// Arrow parameters
PImage leftArrow, rightArrow;
int ARROW_SIZE;

//Keyboard
PImage keyboard;

PImage abc;
PImage def;
PImage ghij;
PImage klmn;
PImage opqr;
PImage stuv;
PImage wxyz;

PImage background;

// Study properties
String[] phrases;                   // contains all the phrases that can be tested
String[] suggestions;               // contains all the predicted words
int NUM_REPEATS            = 2;     // the total number of phrases to be tested
int currTrialNum           = 0;     // the current trial number (indexes into phrases array above)
String currentPhrase       = "";    // the current target phrase
String currentTyped        = "";    // what the user has typed so far
String currentWord         = "";    // word currently being typed
String suggestion          = "the";
String suggestion2         = "of";
char currentLetter         = 'a';
boolean started            = false;
SoundFile keyPress;

// Performance variables
float startTime            = 0;     // time starts when the user clicks for the first time
float finishTime           = 0;     // records the time of when the final trial ends
float lastTime             = 0;     // the timestamp of when the last trial was completed
float lettersEnteredTotal  = 0;     // a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0;     // a running total of the number of letters expected (correct phrases)
float errorsTotal          = 0;     // a running total of the number of errors (when hitting next)

float KEYBOARD_LENGHT = 0;
float KEYBOARD_HEIGHT = 0;
float BUTTON_1_LENGHT = 0;
float BUTTON_1_HEIGHT = 0;

float BUTTON_2_LENGHT = 0;
float BUTTON_2_HEIGHT = 0;

float BUTTON_3_LENGHT = 0;
float BUTTON_3_HEIGHT = 0;

float DELETE_SPACE_LENGHT = 0;
float DELETE_SPACE_HEIGHT = 0;

float RETURN_LENGHT = 0;
float RETURN_HEIGHT = 0;

//Setup window and vars - runs once
void setup()
{
  //size(900, 900);
  fullScreen();
  textFont(createFont("Arial", 24));  // set the font to arial 24
  noCursor();                         // hides the cursor to emulate a watch environment
  
  // Load images
  arm = loadImage("arm_watch.png");
  fingerOcclusion = loadImage("finger.png");
  
  keyboard = loadImage("teclado.png");
  abc = loadImage("abc.png");
  def = loadImage("def.png");
  ghij = loadImage("ghij.png");
  klmn = loadImage("klmn.png");
  opqr = loadImage("opqr.png");
  stuv = loadImage("stuv.png");
  wxyz = loadImage("wxyz.png");
  background = keyboard;
  
  //leftArrow = loadImage("left.png");
  //rightArrow = loadImage("right.png");
  
  //Load common words
  suggestions = loadStrings("count_1w.txt");
  
  // Load a soundfile from the /data folder
  keyPress = new SoundFile(this, "keyPress.mp3");
  
  // Load phrases
  phrases = loadStrings("phrases.txt");                       // load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random());  // randomize the order of the phrases with no seed
  
  // Scale targets and imagens to match screen resolution
  SCALE_FACTOR = 1.0 / displayDensity();          // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");   // the text from the file is loaded into an array.
  PPI = float(ppi_string[1]);                     // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM = PPI / 2.54 * SCALE_FACTOR;               // do not change this!
  
  FINGER_SIZE = (int)(11 * PPCM);
  FINGER_OFFSET = (int)(0.8 * PPCM);
  ARM_LENGTH = (int)(19 * PPCM);
  ARM_HEIGHT = (int)(11.2 * PPCM);
  ARROW_SIZE = (int)(2.2 * PPCM);
  KEYBOARD_LENGHT = (int)(4 * PPCM);
  KEYBOARD_HEIGHT = (int)(3 * PPCM);
  BUTTON_1_LENGHT = (int)(1.2 * PPCM);
  BUTTON_1_HEIGHT = (int)(0.75 * PPCM);
  
  BUTTON_2_LENGHT = (int)(1.2 * PPCM);
  BUTTON_2_HEIGHT = (int)(2 * PPCM);
  
  BUTTON_3_LENGHT = (int)(0.95 * PPCM);
  BUTTON_3_HEIGHT = (int)(2 * PPCM);
  
  RETURN_LENGHT = (int)(4 * PPCM);
  RETURN_HEIGHT = (int)(0.8 * PPCM);
  
  DELETE_SPACE_LENGHT = (int)(0.6 * PPCM);
  DELETE_SPACE_HEIGHT = (int)(0.75 * PPCM);
}

void draw()
{ 
  // Check if we have reached the end of the study
  if (finishTime != 0)  return;
 
  background(255);                                                         // clear background
  
  // Draw arm and watch background
  imageMode(CENTER);
  image(arm, width/2, height/2, ARM_LENGTH, ARM_HEIGHT);  
  
  // Check if we just started the application
  if (startTime == 0 && !mousePressed)
  {
    fill(0);
    textAlign(CENTER);
    text("Tap to start time!", width/2, height/2);
  }
  else if (startTime == 0 && mousePressed) nextTrial();                    // show next sentence
  
  // Check if we are in the middle of a trial
  else if (startTime != 0)
  {
    textAlign(LEFT);
    fill(100);
    text("Phrase " + (currTrialNum + 1) + " of " + NUM_REPEATS, width/2 - 4.0*PPCM, height/2 - 8.1*PPCM);   // write the trial count
    text("Target:    " + currentPhrase, width/2 - 4.0*PPCM, height/2 - 7.1*PPCM);                           // draw the target string
    fill(0);
    text("Entered:  " + currentTyped + "|", width/2 - 4.0*PPCM, height/2 - 6.1*PPCM);                      // draw what the user has entered thus far 
     
    
    // Draw very basic ACCEPT button - do not change this!
    textAlign(CENTER);
    noStroke();
    fill(0, 250, 0);
    rect(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM);
    fill(0);
    text("ACCEPT >", width/2, height/2 - 4.1*PPCM);
    
    // Draw screen areas
    // simulates text box - not interactive
    noStroke();
    fill(125);
    rect(width/2 - 2.0*PPCM, height/2 - 2.0*PPCM, 4.0*PPCM, 1.0*PPCM);
    textAlign(CENTER);
    fill(0);
    textFont(createFont("Arial", 16));  // set the font to arial 24
    text("NOT INTERACTIVE", width/2, height/2 - 1.3 * PPCM);             // draw current letter
    textFont(createFont("Arial", 24));  // set the font to arial 24
    
    // THIS IS THE ONLY INTERACTIVE AREA (4cm x 4cm); do not change size
    

    image(background, width/2, height/2 + 0.5*PPCM, 4.0*PPCM, 3.0*PPCM);
    if(background == keyboard){
      textAlign(CENTER);
      textFont(createFont("Arial", 13));  // set the font to arial 14
      text(suggestion, width/2 - .9*PPCM, height/2 - .5*PPCM);
      text(suggestion2, width/2 + .9*PPCM, height/2 - .5*PPCM);
      textFont(createFont("Arial", 24));  // set the font to arial 24
    }
    
    //image(abc, width/2, height/2 + 0.5*PPCM, 4.0*PPCM, 3.0*PPCM);
    
    /*
    // Write current letter
    textAlign(CENTER);
    fill(0);
    text("" + currentLetter, width/2, height/2);             // draw current letter
    */
    
    /*
    // Draw next and previous arrows
    noFill();
    imageMode(CORNER);
    image(leftArrow, width/2 - ARROW_SIZE, height/2, ARROW_SIZE, ARROW_SIZE);
    image(rightArrow, width/2, height/2, ARROW_SIZE, ARROW_SIZE); 
    */
  }
  
  // Draw the user finger to illustrate the issues with occlusion (the fat finger problem)
  imageMode(CORNER);
  image(fingerOcclusion, mouseX - FINGER_OFFSET, mouseY - FINGER_OFFSET, FINGER_SIZE, FINGER_SIZE);
}

// Check if mouse click was within certain bounds
boolean didMouseClick(float x, float y, float w, float h)
{
  return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
}


void mousePressed()
{

  if (didMouseClick(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM)) nextTrial();                         // Test click on 'accept' button - do not change this!
  else if(didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM))  // Test click on 'keyboard' area - do not change this condition! 
  {
    // YOUR KEYBOARD IMPLEMENTATION NEEDS TO BE IN HERE! (inside the condition)
    /*if (didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM) && background == aux_keyboard) {
      background = abc;
      fill(#3299FF);
      rect(width/2, height/2 + 1.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT);
    }  
      
      fill(#FF9832);
        rect(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_2_LENGHT, BUTTON_2_HEIGHT);
        fill(#3299FF);
        rect(width/2 + 0.775*PPCM, height/2 - 0.940*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT);*/
        
    if (started == false){
      started = true;
      return;
    }
    
    // Test click on 'abc'
    
    if (didMouseClick(width/2 - 1.8*PPCM, height/2 - 0.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = abc;
    }
    
      // Test click on 'a'
      
      else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_2_LENGHT, BUTTON_2_HEIGHT) && background == abc) {
          currentLetter = 'a';
          currentTyped += currentLetter;
          keyPress.play();
          background = keyboard;
      }
      
      // Test click on 'b'
      
      else if (didMouseClick(width/2 - 0.6*PPCM, height/2 - 0.940*PPCM, BUTTON_2_LENGHT, BUTTON_2_HEIGHT) && background == abc) {
        currentLetter = 'b';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'c'
      
      else if (didMouseClick(width/2 + 0.775*PPCM, height/2 - 0.940*PPCM, BUTTON_2_LENGHT, BUTTON_2_HEIGHT) && background == abc) {
        currentLetter = 'c';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
           
      // Test click on 'def'
      
      else if (didMouseClick(width/2 - 0.6*PPCM, height/2 - 0.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = def;
    }
    
    // Test click on 'd'
      
    else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_2_LENGHT, BUTTON_2_HEIGHT) && background == def) {
        currentLetter = 'd';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
    }
      
      // Test click on 'e'
      
      else if (didMouseClick(width/2 - 0.6*PPCM, height/2 - 0.940*PPCM, BUTTON_2_LENGHT, BUTTON_2_HEIGHT) && background == def) {
        currentLetter = 'e';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'f'
      
      else if (didMouseClick(width/2 + 0.6*PPCM, height/2 - 0.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == def) {
        currentLetter = 'f';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'ghij'
      
      else if (didMouseClick(width/2 + 0.6*PPCM, height/2 - 0.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = ghij;
    }
    
    // Test click on 'g'
      
    else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == ghij) {
        currentLetter = 'g';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
    }
      
      // Test click on 'h'
      
      else if (didMouseClick(width/2 - 1.035*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == ghij) {
        currentLetter = 'h';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'i'
      
      else if (didMouseClick(width/2 - 0.005*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == ghij) {
        currentLetter = 'i';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'j'
      
      else if (didMouseClick(width/2 + 1*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == ghij) {
        currentLetter = 'j';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      } 
      
      // Test click on 'klmn'
      
      else if (didMouseClick(width/2 - 1.8*PPCM, height/2 +0.48*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = klmn;
    }
    
    // Test click on 'k'
      
    else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == klmn) {
        currentLetter = 'k';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
    }
      
      // Test click on 'l'
      
      else if (didMouseClick(width/2 - 1.035*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == klmn) {
        currentLetter = 'l';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'm'
      
      else if (didMouseClick(width/2 - 0.005*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == klmn) {
        currentLetter = 'm';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'n'
      
      else if (didMouseClick(width/2 + 1*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == klmn) {
        currentLetter = 'n';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      
       // Test click on 'opqr'
      
      else if (didMouseClick(width/2 - 0.6*PPCM, height/2 +0.48*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = opqr;
    }
    
    // Test click on 'o'
      
    else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == opqr) {
        currentLetter = 'o';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
    }
      
      // Test click on 'p'
      
      else if (didMouseClick(width/2 - 1.035*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == opqr) {
        currentLetter = 'p';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'q'
      
      else if (didMouseClick(width/2 - 0.005*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == opqr) {
        currentLetter = 'q';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'r'
      
      else if (didMouseClick(width/2 + 1*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == opqr) {
        currentLetter = 'r';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      
      // Test click on 'stuv'
      
      else if (didMouseClick(width/2 + 0.775*PPCM, height/2 +0.11*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = stuv;
    }
    
    // Test click on 's'
      
    else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == stuv) {
        currentLetter = 's';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
    }
      
      // Test click on 't'
      
      else if (didMouseClick(width/2 - 1.035*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == stuv) {
        currentLetter = 't';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'u'
      
      else if (didMouseClick(width/2 - 0.005*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == stuv) {
        currentLetter = 'u';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      } 
      
      // Test click on 'v'
      
      else if (didMouseClick(width/2 + 1*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == stuv) {
        currentLetter = 'v';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      } 
      
      // Test click on 'wxyz'
      
      else if (didMouseClick(width/2 - 0.6*PPCM, height/2 + 1.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard)
    {
      keyPress.play();
      background = wxyz;
    }
    
    // Test click on 'w'
      
    else if (didMouseClick(width/2 - 1.975*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == wxyz) {
        currentLetter = 'w';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
    }
      
      // Test click on 'x'
      
      else if (didMouseClick(width/2 - 1.035*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == wxyz) {
        currentLetter = 'x';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      }  
      
      // Test click on 'y'
      
      else if (didMouseClick(width/2 - 0.005*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == wxyz) {
        currentLetter = 'y';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      } 
      
      // Test click on 'z'
      
      else if (didMouseClick(width/2 + 1*PPCM, height/2 - 0.940*PPCM, BUTTON_3_LENGHT, BUTTON_3_HEIGHT) && background == wxyz) {
        currentLetter = 'z';
        currentTyped += currentLetter;
        keyPress.play();
        background = keyboard;
      } 
      
      // Test click on 'DELETE'
      
      else if (didMouseClick(width/2 + 0.6*PPCM, height/2 + 1.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && currentTyped.length() > 0 && background == keyboard){
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
        keyPress.play();
      } 
      
      // Test click on 'SPACE'
      
      else if (didMouseClick(width/2 - 1.8*PPCM, height/2 + 1.24*PPCM, BUTTON_1_LENGHT, BUTTON_1_HEIGHT) && background == keyboard) {
        currentTyped+=" ";
        keyPress.play();
      }
      
      // Test click on 'RETURN'
      
      else if (didMouseClick(width/2 - 2.*PPCM, height/2 + 1.15*PPCM, RETURN_LENGHT, RETURN_HEIGHT)) {
        background = keyboard;
        keyPress.play();
      }  
      
      // Test click on 1st suggestion
      
      else if (didMouseClick(width/2 - 1.1*(KEYBOARD_LENGHT/2), height/2 - 0.24*PPCM - BUTTON_1_HEIGHT, KEYBOARD_LENGHT/2, BUTTON_1_HEIGHT) && background == keyboard && suggestion != "----"){
        currentTyped = currentTyped.substring(0, currentTyped.length() - split(currentTyped, " ")[split(currentTyped, " ").length -1].length()); 
        currentTyped += suggestion + " ";
        keyPress.play();
      }
      
      // Test click on 2nd suggestion

      else if (didMouseClick(width/2 - 0.1*(KEYBOARD_LENGHT/2), height/2 - 0.24*PPCM - BUTTON_1_HEIGHT, KEYBOARD_LENGHT/2, BUTTON_1_HEIGHT) && background == keyboard && suggestion2 != "----"){
        currentTyped = currentTyped.substring(0, currentTyped.length() - split(currentTyped, " ")[split(currentTyped, " ").length -1].length()); 
        currentTyped += suggestion2 + " ";
        keyPress.play();
      }
    /*
    // Test click on left arrow
    if (didMouseClick(width/2 - ARROW_SIZE, height/2, ARROW_SIZE, ARROW_SIZE))
    {
      currentLetter--;
      if (currentLetter < '_') currentLetter = 'z';                  // wrap around to z
    }
    // Test click on right arrow
    else if (didMouseClick(width/2, height/2, ARROW_SIZE, ARROW_SIZE))
    {
      currentLetter++;
      if (currentLetter > 'z') currentLetter = '_';                  // wrap back to space (aka underscore)
    }
    // Test click on keyboard area (to confirm selection)
    else
    {
      if (currentLetter == '_') currentTyped+=" ";                   // if underscore, consider that a space bar
      else if (currentLetter == '`' && currentTyped.length() > 0)    // if `, treat that as a delete command
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
      else if (currentLetter != '`') currentTyped += currentLetter;  // if not any of the above cases, add the current letter to the typed string
    }*/
  }
  else System.out.println("debug: CLICK NOT ACCEPTED");
  
  //Predict next word
  int i = 0;
  if(currentTyped.length() == 0 || currentTyped.charAt(currentTyped.length() -1) == ' '){
    suggestion = "the";
    suggestion2 = "of";
  }
  else{
    currentWord = split(currentTyped, " ")[split(currentTyped, " ").length -1];

    for(i = 0; suggestions[i].indexOf(currentWord) != 0 && i < 333332; i++); // search for word to suggest
    if(i == 333332) { // if word was not found
      suggestion = suggestion2 = "----";
      return; 
      }
    else suggestion = split(suggestions[i], TAB)[0]; // if word was found
    
    for(i++; suggestions[i].indexOf(currentWord) != 0 && i < 333332; i++); // search for word to suggest again
    if(i == 333332) suggestion2 = "----"; // if word was not found
    else suggestion2 = split(suggestions[i], TAB)[0]; // if word was found
  }
  
  
}

  
void nextTrial()
{
  if (currTrialNum >= NUM_REPEATS) return;                                            // check to see if experiment is done
  
  // Check if we're in the middle of the tests
  else if (startTime != 0 && finishTime == 0)                                         
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + NUM_REPEATS);
    System.out.println("Target phrase: " + currentPhrase);
    System.out.println("Phrase length: " + currentPhrase.length());
    System.out.println("User typed: " + currentTyped);
    System.out.println("User typed length: " + currentTyped.length());
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim()));
    System.out.println("Time taken on this trial: " + (millis() - lastTime));
    System.out.println("Time taken since beginning: " + (millis() - startTime));
    System.out.println("==================");
    lettersExpectedTotal += currentPhrase.trim().length();
    lettersEnteredTotal += currentTyped.trim().length();
    errorsTotal += computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }
  
  // Check to see if experiment just finished
  if (currTrialNum == NUM_REPEATS - 1)                                           
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime));
    System.out.println("Total letters entered: " + lettersEnteredTotal);
    System.out.println("Total letters expected: " + lettersExpectedTotal);
    System.out.println("Total errors entered: " + errorsTotal);

    float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f);   // FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal * .05;                                 // no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal - freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm);
    System.out.println("Freebie errors: " + freebieErrors);
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm - penalty));                         // yes, minus, because higher WPM is better
    System.out.println("==================");
    
    printResults(wpm, freebieErrors, penalty);
    
    currTrialNum++;                                                                   // increment by one so this mesage only appears once when all trials are done
    return;
  }

  else if (startTime == 0)                                                            // first trial starting now
  {
    System.out.println("Trials beginning! Starting timer...");
    startTime = millis();                                                             // start the timer!
  } 
  else currTrialNum++;                                                                // increment trial number

  lastTime = millis();                                                                // record the time of when this trial ended
  currentTyped = "";  // clear what is currently typed preparing for next trial
  currentWord = "";
  currentPhrase = phrases[currTrialNum];                                              // load the next phrase!
}

// Print results at the end of the study
void printResults(float wpm, float freebieErrors, float penalty)
{
  background(0);       // clears screen
  
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen
  
  text("Finished!", width / 2, height / 2); 
  text("Raw WPM: " + wpm, width / 2, height / 2 + 20);
  text("Freebie errors: " + freebieErrors, width / 2, height / 2 + 40);
  text("Penalty: " + penalty, width / 2, height / 2 + 60);
  text("WPM with penalty: " + (wpm - penalty), width / 2, height / 2 + 80);

  saveFrame("results-######.png");    // saves screenshot in current folder    
}

// This computes the error between two strings (i.e., original phrase and user input)
int computeLevenshteinDistance(String phrase1, String phrase2)
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++) distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++) distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
