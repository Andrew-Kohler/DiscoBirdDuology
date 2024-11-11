import processing.sound.SoundFile;

/* Welcome back, again!

This was ... well, for all the trouble it was, I enjoyed making it. I hope you like it too!
As the manual states, this project does use the official Processing Sound library.
     
---------------------------------------------------------
    
*/

int state;        // Int for keeping track of what state the game is in: 0 = Main Menu, 1 = Gameplay, 2 = Victory, 3 = Defeat
int myTurn;       // Allows for more measured control over turn length
int chosenAction; // Tracks the chosen action of the active Being in combat
int targetIndex;  // Index in turnOrder of being that is targeted by an action
int allyXMod;     // Used for moving allies off screen for victories
int allyYMod;
int floorCount;   // Int that keeps track of what floor the player is on
int finalFloor;   // Int that tracks what floor is the last one (different between difficulty modes)


boolean inferno;  // The boolean that keeps track of the selected difficulty mode
boolean newFloor;  // The boolean that ensures an encounter is only generated once per floor
boolean newFloor2; // Allows for allies to walk into the room at the start of combat
boolean newTurn;  // Ensures that turn start flavor text doesn't keep repeating itself
boolean startLoop; // Ensures that we don't continuously set a music track to loop every iteration of draw()

boolean loaded;  // Ensures tracks are only ever loaded once
int loadCount; // Allows for text to change on the loading screen

boolean check;  // Four global booleans both associated with ensuring that clicking one set of buttons does not activate the other set
boolean load;
boolean check2;
boolean load2;

Being target;       // The target of the current attack or spell
Being[] beings;     // The array containing 6 slots for beings on the field: 0 = Ally 1, 1 = Disco Bird, 2 = Ally 2, 3 = Enemy 1, 4 = Enemy 2, 5 = Enemy 3
Being[] turnOrder;  // The array that represents the attacking order of everyone currently on screen
String flavorText;  // Text that will read out a fun description of the most recent action taken

PFont gameFont;
PImage titleScreen;
PImage loadScreen;
PImage logo;
PImage indicator;
PImage[] menuButtonBoxes;  // O = Start, 1 = Disco Destiny / Main Menu (Win), 2 = Disco Inferno / Main Menu (Loss)
                           // 3 = Quit, 4 = Atk Choice, 5 = Enemy Choice, 6 = HP / GR indicator
PImage[] gameBackgrounds;  // 0 = L1, 1 = L1 Inferno, 2 = L2, 3 = L2 Inferno, 4 = L3, 5 = L3 Inferno
                           // 6 = Final Boss, 7 = Final Boss Inferno, 8 = Victory, 9 = Defeat
PImage[] battleFX;         // 0 = Attack, 1 = Heal, 2 = Revive, 3 = GRV Up/Recruit, 4 = Beat Stop, 5 = ???, 6 = Active Turn

SoundFile sound0;  // 0 = Main Menu, 1 = Battle 1, 2 = Battle 2, 3 = Battle 3, 4 = Final Battle, 5 = Select 1, 6 = Select 2
SoundFile sound1;
SoundFile sound2;
SoundFile sound3;
SoundFile sound4;
SoundFile sound5;
SoundFile sound6;


void setup(){
  // Standard setup
  size(720, 800); // x5  144, 160
  // Variable initialization
  state = 0;
  myTurn = 0;
  chosenAction = -1;
  targetIndex = -1;
  allyXMod = 0;
  allyYMod = 0;
  floorCount = 0;
  finalFloor = 15;
  loadCount = 0;
  
  inferno = false;
  newFloor = true;
  newFloor2 = true;
  newTurn = true;
  startLoop = true;
  loaded = false;
  
  check = true;
  load = false;
  check2 = true;
  load2 = false;
  
  loadScreen = loadImage("Load.png");
  image(loadScreen, 0, 0);
  textSize(52);
  textAlign(CENTER);
  text("Loading in some funky tunes... ", width/2, 350);
  textSize(32);
  text("(Takes about 17 seconds)", width/2, 390);
  textAlign(LEFT);
  
  gameFont = loadFont("TwCenMT-Regular-48.vlw");
  textFont(gameFont, 48);
  menuButtonBoxes = new PImage[7];
  gameBackgrounds = new PImage[10];
  battleFX = new PImage[7];
  
  // Load in all images relevant to main
  titleScreen = loadImage("DBatDOoD Title Screen.png");
  
  logo = loadImage("Logo.png");
  indicator = loadImage("Bird/DiscoBird2.png");
  for(int i = 0; i < 7; i++){
    String file = "Menu/Button";
    file += Integer.toString(i);
    file += ".png";
    menuButtonBoxes[i] = loadImage(file);
  }
  for(int j = 0; j < 10; j++){
    String file = "BG/BG";
    file += Integer.toString(j);
    file += ".png";
    gameBackgrounds[j] = loadImage(file);
  }
  for(int k = 0; k < 7; k++){
    String file = "FX/FX";
    file += Integer.toString(k);
    file += ".png";
    battleFX[k] = loadImage(file);
  }

  textAlign(LEFT);
  
  // Set up gameplay arrays
  beings = new Being[6];
  turnOrder = new Being[6];
  for(int n = 0; n < 6; n++){
   beings[n] = null;
   turnOrder[n] = null; 
  }
  
  flavorText = "";

}

void draw(){
  if(state == 0){  // State 0: Main menu
    if(startLoop){  // Loop the main menu track
    
     if(loaded == false){
      sound0 = new SoundFile(this, "Sound/Track0.mp3");
      sound1 = new SoundFile(this, "Sound/Track1.mp3");
      sound2 = new SoundFile(this, "Sound/Track2.mp3");
      sound3 = new SoundFile(this, "Sound/Track3.mp3");
      sound4 = new SoundFile(this, "Sound/Track4.mp3");
      sound6 = new SoundFile(this, "Sound/Track6.mp3");
      sound6.amp(.5);
      loaded = true;
     }
     sound0.loop();
     
     startLoop = false;

    }
    textAlign(LEFT);
    image(titleScreen, 0, 0);  // Draw in the image background
    image(logo, 120, 20);  // Draw in the logo
    mainMenu();            // Draw in all the buttons
    beings[1] = new Being("Bird", 1, 1, true);

    // Set the Destiny/Inferno Toggle settings and draw the buttons differently based on which one is selected
    if(inferno){
      finalFloor = 25;
      scale(-1, 1);
      image(indicator, -650, 250);
    }
    else{
      finalFloor = 15;
      image(indicator, 50, 250);
    }
    
    
    
  } // End of State 0 --------------------------------------------------------------------------
  
  else if(state == 1){  // State 1: Active Gameplay
    
    if(newFloor){
      //if(floorCount + 1 < finalFloor){  // Generate a new set of enemies
      //  //beings[2] = new Being("Ooze", 1, 1, true);
      //  beings[3] = new Being("Hawk", 2, 1, false);
      //  //beings[4] = new Being("Ooze", 1, 1, true);
        
      //  //beings[5] = new Being("Ooze", 1, 1, false);
      //}
      //else if(floorCount + 1 == finalFloor){  // No enemy generation necessary; just load in the boss
      //  beings[3] = new Being("Hawk", 2, 1, false);
      //}
      Being[] enemies = encounterGenerator(floorCount);
      beings[3] = enemies[0];
      beings[4] = enemies[1];
      beings[5] = enemies[2];
      
      turnOrderCalc(beings);  // Re-calculate turn order
      myTurn = 0;
      newFloor = false;       // Having completed setup procedures, bar us from entering this "if" statement until we go to a new floor
      if(floorCount + 1 != 1){
        currentBG(floorCount);
      }
      allyXMod = -300;
      newFloor2 = true;
      
      if(floorCount + 1 == 1 || floorCount + 1 == 6 || floorCount + 1 == 11 || floorCount + 1 == 15 || floorCount + 1 == 16 || floorCount + 1 == 21 || floorCount + 1 == 25){
      startLoop = true;
    }
  
    if(startLoop){
      if(inferno){
        if(floorCount + 1 == 1){
          sound0.stop();
          sound1.loop();
        }
        else if(floorCount + 1 == 11){
          sound1.stop();
          sound2.loop();
        }
        else if(floorCount + 1 == 21){
          sound2.stop();
          sound3.loop();
        }
        else if(floorCount + 1 == 25){
          sound3.stop();
          sound4.loop();
        }
      }
      else{
        if(floorCount + 1 == 1){
          sound0.stop();
          sound1.loop();
        }
        else if(floorCount + 1 == 6){
          sound1.stop();
          sound2.loop();
        }
        else if(floorCount + 1 == 11){
          sound2.stop();
          sound3.loop();
        }
        else if(floorCount + 1 == 15){
          sound3.stop();
          sound4.loop();
        }
        
      }
      startLoop = false;
      
    }
      
    }
    
    if(newFloor2){
      if(floorCount + 1 != 1){
        currentBG(floorCount);
        redrawBeings(turnOrder, allyXMod, 0, allyXMod);
      }
      allyXMod += 10;
      if(allyXMod == 0){
       newFloor2 = false; 
      }
    }
    else{
      
      currentBG(floorCount); // Draw the relevant background
      if(!allEnemiesDown(turnOrder)){
        redrawBeings(turnOrder, 0, 0, 0);
      }
      drawAllyStats(turnOrder);
      if(newTurn){
       delay(1750); //The delay allows for the player to read the flavor text relating to the last action taken before it's cleared
      }

      if(allEnemiesDown(turnOrder)){  // If all enemies are down
        newTurn = false;
        if(floorCount + 1 == 15){
          flavorText = "Disco Bird wins! The Hawk of Hate is vanquished!";
        }
        else{
          flavorText = "Disco Bird wins! Onward to the next floor!";
        }
        
        myTurn = -1;
        
        if(floorCount + 1 == 5 || floorCount + 1 == 10){  // Move allies across the screen like they are leaving
          redrawBeings(turnOrder, 0, allyYMod, 0);
          allyYMod -= 5;
        }
        else{
          redrawBeings(turnOrder, allyXMod, 0, 0);
          allyXMod += 5;
        }
        
        if(allyXMod > 720 || allyYMod < -400){  // Once the desired effect has been achieved with movement
          int xpTotal = 0;
          int count = 0;
          
          for(int j = 0; j < turnOrder.length; j++){ // If there are any enemies left in turnOrder, add their XP to a total, then get rid of them
            if(turnOrder[j] != null){
              if(!turnOrder[j].ally){
                xpTotal += turnOrder[j].XPYield;
                turnOrder[j] = null;
              }
            } 
          }
          
          for(int k = 0; k < turnOrder.length; k++){ // Give allies XP from the fight and add them back into beings to be re-speed checked
            if(turnOrder[k] != null){
              turnOrder[k].changeXP(xpTotal);
              beings[count] = turnOrder[k];
              turnOrder[k] = null;
              count++;
            } 
          }
          
          if(floorCount + 1 == finalFloor){  // Finally, leave the current floor behind in the approriate manner
            state = 2;
          }
          else if(floorCount + 1 < finalFloor){
           floorCount++;
           newFloor = true;
           newFloor2 = false;
           allyXMod = 0;
           allyYMod = 0;
          }
        } 
      }
      
      else if(allAlliesDown(turnOrder)){  // If all allies are down
        state = 3;
      }

      else if(turnOrder[myTurn] != null){  // If there are still allies and enemies on the board
        
        
        if(turnOrder[myTurn].ally){  // If the current turn taker is an ally
          if(turnOrder[myTurn].down){  // If the ally is down, keep moving
            flavorText = turnOrder[myTurn].name + " is off the dance floor!";
            newTurn = true;
            myTurn++;  
          }
          else if(turnOrder[myTurn].stopped){  // If the ally is beat-stopped
          int escape = (int)random(0, 100);
            if(turnOrder[myTurn].LVL == 1){    // Breakout chance is determined by level
              if(escape <= 20){
                turnOrder[myTurn].beatStop(false);
                flavorText = turnOrder[myTurn].name + " has found their rhythm!";   
              }
              else{
                flavorText = turnOrder[myTurn].name + " is beat-stopped and can't dance!";
              }
            }
            else if(turnOrder[myTurn].LVL == 2){
              if(escape <= 25){
                turnOrder[myTurn].beatStop(false);
                flavorText = turnOrder[myTurn].name + " has found their rhythm!";
              }
              else{
                flavorText = turnOrder[myTurn].name + " is beat-stopped and can't dance!";
              }
            }
            else if(turnOrder[myTurn].LVL == 3){
              if(escape <= 30){
                turnOrder[myTurn].beatStop(false);
                flavorText = turnOrder[myTurn].name + " has found their rhythm!";
              }
              else{
                flavorText = turnOrder[myTurn].name + " is beat-stopped and can't dance!";
              }
            }
            newTurn = true;
            turnOrder[myTurn].changeGRV(2);
            myTurn++;
          } 
            
        else{  // No status FX preventing turn taking; proceed w/ turn
          if(newTurn){
            flavorText = "It's " + turnOrder[myTurn].name + "'s time to shine!";  // Ensures that the "turn start" flavor text doesn't keep popping up
            newTurn = false;
            turnOrder[myTurn].changeGRV(2);
          }
              
          if(chosenAction == -1){        // Prompt the player to choose an action 
            playerAction(turnOrder[myTurn]);
          }
          else if(chosenAction != -1){   // Once an action has been chosen, ask the player to choose an appropriate target  
            flavorText = "Who will you act on?";
            
            if(targetIndex == -1){
              playerTarget(chosenAction, turnOrder);
            }
            else if(targetIndex != -1){
              // Perform the action on the target, change flavor text appropriately
              act(chosenAction, turnOrder[myTurn], targetIndex);
              
               targetIndex = -1;   // Reset it all for the next turn
               newTurn = true;
               check = true;
               load = false;
               check2 = true;
               load2 = false;
               chosenAction = -1;
               myTurn++;
               
            }
          }    
        }          
      } // End of ally section
          
      else if(!turnOrder[myTurn].ally){  // If the current turn taker is an enemy
        if(turnOrder[myTurn].down){  // If the enemy is down
          flavorText = turnOrder[myTurn].name + " is off the dance floor!";
          newTurn = true;
          myTurn++;
        }
        else if(turnOrder[myTurn].stopped){  // If the enemy is beat-stopped
          int escape = (int)random(0, 100);
          if(turnOrder[myTurn].LVL == 1){    // Breakout chance is determined by level
            if(escape <= 20){
              turnOrder[myTurn].beatStop(false);
              flavorText = turnOrder[myTurn].name + " has found their rhythm!";      
            }
            else{
              flavorText = turnOrder[myTurn].name + " is beat-stopped and can't dance!";
            }
          }
          else if(turnOrder[myTurn].LVL == 2){
            if(escape <= 25){
              turnOrder[myTurn].beatStop(false);
              flavorText = turnOrder[myTurn].name + " has found their rhythm!";
            }
            else{
             flavorText = turnOrder[myTurn].name + " is beat-stopped and can't dance!"; 
            }
          }
          else if(turnOrder[myTurn].LVL == 3){
            if(escape <= 30){
              turnOrder[myTurn].beatStop(false);
              flavorText = turnOrder[myTurn].name + " has found their rhythm!";
            }
            else{
             flavorText = turnOrder[myTurn].name + " is beat-stopped and can't dance!"; 
            }
          }
          newTurn = true;
          turnOrder[myTurn].changeGRV(2);
          myTurn++;
        }
        else{  // No status FX preventing turn taking; proceed w/ turn
          if(newTurn){
            flavorText = "It's " + turnOrder[myTurn].name + "'s chance to strike!";   // Ensures that the "turn start" flavor text doesn't keep popping up
            newTurn = false;
            turnOrder[myTurn].changeGRV(2);
          }
          chosenAction = turnOrder[myTurn].enemyAI(turnOrder);  // Select an action to perform
          targetIndex = turnOrder[myTurn].enemyTargetAI(chosenAction, turnOrder); // Select a target to perform the action on
          act(chosenAction, turnOrder[myTurn], targetIndex);    // Perform the action on the target
          
          targetIndex = -1;   // Reset it all for the next turn
          newTurn = true;
          chosenAction = -1;
          myTurn++;

        }
            
      } // End of enemy section
          
    } // End of if statement for if turnOrder[myTurn] is null
      
    else{
      newTurn = false;
      myTurn++;
    }
    
    fill(255);
    if(textWidth(flavorText) > 350){  // Ensures flavor text never escapes the box
      textSize(20);
    }
    else{
      textSize(28);
    }
    
    text(flavorText, 20, 607);  // Displays flavor text for what's happening
    
    if(myTurn == 6){  // Resets turn cycle
     myTurn = 0; 
     newTurn = true;
    }
   } // end of else for newFloor2   
    
  } // End of State 1 --------------------------------------------------------------------------
  
  else if(state == 2){  // State 2: Victory
  image(gameBackgrounds[8], 0, 0);  // Draw in the background
  sound4.stop();
  sound0.loop();
  
  fill(255);
  textSize(150);  // VICTORY
  textAlign(CENTER);
  text("VICTORY", width/2, 200);
  
  textSize(28);  // Draw congratulatory text
  if(inferno){
    text("The Heinous Hawk of Hate is no more! Sweet dreams, Disco Bird!", width/2, 250);
    text("THANK YOU FOR PLAYING!", width/2, 575);
    textSize(18);
    text("Disco Bird and the Dance Off of Destiny: A game by Andrew Kohler", width/2, 595);
  }
  else{
    text("The Hawk of Hate's horrible plan is foiled, and the land is saved!", width/2, 250);
    text("Thank you, Disco Bird!", width/2, 275);
    text("A NEW CHALLENGE AWAITS...TRY DISCO INFERNO MODE!", width/2, 575);
  }
  
  floorCount = 0;
  targetIndex = -1;   // Reset it all for the next go
  newTurn = true;
  check = true;
  load = false;
  check2 = true;
  load2 = false;
  chosenAction = -1;
  myTurn = 0;
  newFloor = true;
  newFloor2 = true;
  
  endingDraw(beings, true); // Draw in the team's sprites
  
  textSize(52);
  textAlign(LEFT);
  Button menu = new Button(200, 600, 320, 80, menuButtonBoxes[1], "Main Menu"); // Draw in the "Main Menu" button 
  menu.drawButton();
  if(menu.pressed()){
   beings[0] = null;
   beings[1] = null;
   beings[2] = null;
   beings[3] = null;
   beings[4] = null;
   beings[5] = null;
   sound6.play();
   state = 0; 
  }
    
  } // End of State 2 --------------------------------------------------------------------------
  
  else if(state == 3){  // State 3: Defeat
  image(gameBackgrounds[9], 0, 0);  // Draw in the background
  sound1.stop();
  sound2.stop();
  sound3.stop();
  sound4.stop();
  sound0.loop();
  
    fill(255);
    textSize(150);  // DEFEAT
    textAlign(CENTER);
    text("DEFEAT", width/2, 200);
     
    if(inferno){  // Draw text
      textSize(24);
      text("This ne'er-do-well nightmare must have an end! Press on, Disco Bird!", width/2, 250);
    }
    else{
      textSize(28);
      text("There is yet time to save the day! Take heart, Disco Bird!", width/2, 250);
    }
    
    floorCount = 0;
    targetIndex = -1;   // Reset it all for the next go
    newTurn = true;
    check = true;
    load = false;
    check2 = true;
    load2 = false;
    chosenAction = -1;
    myTurn = 0;
    newFloor = true;
    newFloor2 = true;
    
    endingDraw(beings, false); // Draw in the team's sprites
    
    textSize(52);
    textAlign(LEFT);
    Button menu = new Button(200, 600, 320, 80, menuButtonBoxes[2], "Main Menu"); // Draw in the "Main Menu" button 
    menu.drawButton();
    if(menu.pressed()){
     sound6.play();
     beings[0] = null;
     beings[1] = null;
     beings[2] = null;
     beings[3] = null;
     beings[4] = null;
     beings[5] = null;
     state = 0; 
    }
    
  } // End of State 3 --------------------------------------------------------------------------
  
} // End of draw() --------------------------------------------------------------------------

// Below are methods that are practical but don't fit into any one class
Being[] encounterGenerator(int currentFloor){ // A method that generates enemy encounters based on what floor the player is on
  Being[] encounter = new Being[3];
  currentFloor = currentFloor + 1;
  int randomTwoLvl = (int)random(1, 2.1);    // Random level generators
  int randomTwoLvl2 = (int)random(1, 2.1);
  int randomTwoLvl3 = (int)random(1, 2.1);
  int randomThreeLvl = (int)random(1, 3.1);
  int randomThreeLvl2 = (int)random(1, 3.1);
  int randomThreeLvl3 = (int)random(1, 3.1);
  
  int randomVal = (int)random(0, 100);
  int randomVal1 = (int)random(0, 100);
  int randomVal2 = (int)random(0, 100);
  
  if(inferno){  // Disco Inferno generation patterns are more difficult
    if(currentFloor == 1){
      encounter[0] = new Being("Ooze", 2, 1, false);
    }
    else if(currentFloor == 2){
      if(randomVal > 50){
        encounter[0] = new Being("Ooze", 1, 1, false);
      }
      else{
        encounter[0] = new Being("Ooze", 2, 1, false);
      }
      if(randomVal1 > 50){
        encounter[1] = new Being("Ooze", 1, 1, false);
      }
      else{
        encounter[1] = new Being("Ooze", 2, 1, false);
      }
      if(randomVal1 > 50){
        encounter[2] = new Being("Ooze", 1, 1, false);
      }
      else{
        encounter[2] = new Being("Ooze", 2, 1, false);
      }
    }
    else if(currentFloor == 3){
      if(randomVal > 66){
        encounter[0] = new Being("Ooze", 1, 1, false);
      }
      else if(randomVal > 33 && randomVal <= 66){
        encounter[0] = new Being("Ooze", 2, 1, false);
      }
      else{
        encounter[0] = new Being("Leoger", 1, 1, false);
      }
      if(randomVal1 > 66){
        encounter[1] = new Being("Ooze", 1, 1, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[1] = new Being("Ooze", 2, 1, false);
      }
      else{
        encounter[1] = new Being("Leoger", 2, 1, false);
      }
      if(randomVal1 > 66){
        encounter[2] = new Being("Ooze", 1, 1, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[2] = new Being("Ooze", 2, 1, false);
      }
      else{
        encounter[2] = new Being("Leoger", 2, 1, false);
      }
    }
    else if(currentFloor == 4){
      if(randomVal > 66){
        encounter[0] = new Being("Leoger", 2, randomTwoLvl, false);
      }
      else if(randomVal > 33 && randomVal <= 66){
        encounter[0] = new Being("Ooze", 2, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Leoger", 1, randomTwoLvl, false);
      }
      if(randomVal1 > 66){
        encounter[1] = new Being("Leoger", 2, randomTwoLvl2, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[1] = new Being("Ooze", 2, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Leoger", 1, randomTwoLvl2, false);
      }
      if(randomVal1 > 66){
        encounter[2] = new Being("Leoger", 2, randomTwoLvl3, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[2] = new Being("Ooze", 2, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Leoger", 1, randomTwoLvl3, false);
      }
    }
    else if(currentFloor == 5){
      if(randomVal > 75){
        encounter[0] = new Being("Ooze", 2, randomTwoLvl, false);
      }
      else if(randomVal > 50 && randomVal <= 75){
        encounter[0] = new Being("Ooze", 3, randomTwoLvl, false);
      }
      else if(randomVal > 25 && randomVal <= 50){
        encounter[0] = new Being("Leoger", 1, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Leoger", 2, randomTwoLvl, false);
      }
      
      if(randomVal1 > 75){
        encounter[1] = new Being("Ooze", 2, randomTwoLvl2, false);
      }
      else if(randomVal1 > 50 && randomVal1 <= 75){
        encounter[1] = new Being("Ooze", 3, randomTwoLvl2, false);
      }
      else if(randomVal1 > 25 && randomVal1 <= 50){
        encounter[1] = new Being("Leoger", 1, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Leoger", 2, randomTwoLvl2, false);
      }
      
      if(randomVal2 > 75){
        encounter[2] = new Being("Ooze", 2, randomTwoLvl3, false);
      }
      else if(randomVal2 > 50 && randomVal2 <= 75){
        encounter[2] = new Being("Ooze", 3, randomTwoLvl3, false);
      }
      else if(randomVal2 > 25 && randomVal2 <= 50){
        encounter[2] = new Being("Leoger", 1, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Leoger", 2, randomTwoLvl3, false);
      }
    }
    else if(currentFloor >= 6 && currentFloor <= 10){
      if(randomVal < 20){
         encounter[0] = new Being("Ooze", 2, randomTwoLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 20){
         encounter[0] = new Being("Ooze", 3, randomTwoLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 60){
         encounter[0] = new Being("Leoger", 2, randomTwoLvl, false);
      }
      else if(randomVal < 60 && randomVal >= 80){
         encounter[0] = new Being("Skeleton", 1, randomTwoLvl, false);
      }
      else{
         encounter[0] = new Being("Skeleton", 2, randomTwoLvl, false);
      }
      
      if(randomVal1 < 20){
         encounter[1] = new Being("Ooze", 2, randomTwoLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 20){
         encounter[1] = new Being("Ooze", 3, randomTwoLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 60){
         encounter[1] = new Being("Leoger", 2, randomTwoLvl2, false);
      }
      else if(randomVal1 < 60 && randomVal1 >= 80){
         encounter[1] = new Being("Skeleton", 1, randomTwoLvl2, false);
      }
      else{
         encounter[1] = new Being("Skeleton", 2, randomTwoLvl2, false);
      }
      
      if(randomVal2 < 20){
         encounter[2] = new Being("Ooze", 2, randomTwoLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 20){
         encounter[2] = new Being("Ooze", 3, randomTwoLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 60){
         encounter[2] = new Being("Leoger", 2, randomTwoLvl3, false);
      }
      else if(randomVal2 < 60 && randomVal2 >= 80){
         encounter[2] = new Being("Skeleton", 1, randomTwoLvl3, false);
      }
      else{
         encounter[2] = new Being("Skeleton", 2, randomTwoLvl3, false);
      }
      
    }
    else if(currentFloor >= 16 && currentFloor <= 19){
      if(randomVal < 20){
         encounter[0] = new Being("Skeleton", 3, randomThreeLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 20){
         encounter[0] = new Being("Leoger", 3, randomThreeLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 60){
         encounter[0] = new Being("Wizard", 1, randomThreeLvl, false);
      }
      else if(randomVal < 60 && randomVal >= 80){
         encounter[0] = new Being("Demon", 1, randomThreeLvl, false);
      }
      else{
         encounter[0] = new Being("Demon", 2, randomThreeLvl, false);
      }
      
      if(randomVal1 < 20){
         encounter[1] = new Being("Skeleton", 3, randomThreeLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 20){
         encounter[1] = new Being("Leoger", 3, randomThreeLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 60){
         encounter[1] = new Being("Wizard", 1, randomThreeLvl2, false);
      }
      else if(randomVal1 < 60 && randomVal1 >= 80){
         encounter[1] = new Being("Demon", 1, randomThreeLvl2, false);
      }
      else{
         encounter[1] = new Being("Demon", 2, randomThreeLvl2, false);
      }
      
      if(randomVal2 < 20){
         encounter[2] = new Being("Skeleton", 3, randomThreeLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 20){
         encounter[2] = new Being("Leoger", 3, randomThreeLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 60){
         encounter[2] = new Being("Wizard", 1, randomThreeLvl3, false);
      }
      else if(randomVal2 < 60 && randomVal2 >= 80){
         encounter[2] = new Being("Demon", 1, randomThreeLvl3, false);
      }
      else{
         encounter[2] = new Being("Demon", 2, randomThreeLvl3, false);
      }
    }
    else if(currentFloor >= 11 && currentFloor <= 15){
       if(randomVal < 20){
         encounter[0] = new Being("Ooze", 3, randomThreeLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 20){
         encounter[0] = new Being("Leoger", 3, randomThreeLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 60){
         encounter[0] = new Being("Leoger", 2, randomThreeLvl, false);
      }
      else if(randomVal < 60 && randomVal >= 80){
         encounter[0] = new Being("Demon", 1, randomThreeLvl, false);
      }
      else{
         encounter[0] = new Being("Skeleton", 2, randomThreeLvl, false);
      }
      
      if(randomVal1 < 20){
         encounter[1] = new Being("Ooze", 3, randomThreeLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 20){
         encounter[1] = new Being("Leoger", 3, randomThreeLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 60){
         encounter[1] = new Being("Leoger", 2, randomThreeLvl2, false);
      }
      else if(randomVal1 < 60 && randomVal1 >= 80){
         encounter[1] = new Being("Demon", 1, randomThreeLvl2, false);
      }
      else{
         encounter[1] = new Being("Skeleton", 2, randomThreeLvl2, false);
      }
      
      if(randomVal2 < 20){
         encounter[2] = new Being("Ooze", 3, randomThreeLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 20){
         encounter[2] = new Being("Leoger", 3, randomThreeLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 60){
         encounter[2] = new Being("Leoger", 2, randomThreeLvl3, false);
      }
      else if(randomVal2 < 60 && randomVal2 >= 80){
         encounter[2] = new Being("Demon", 1, randomThreeLvl3, false);
      }
      else{
         encounter[2] = new Being("Skeleton", 2, randomThreeLvl3, false);
      }
    }
    else if(currentFloor == 20){
      encounter[0] = new Being("Ooze", 1, 3, false);  // The Ooze floor :D
      encounter[1] = new Being("Ooze", 2, 3, false);
      encounter[2] = new Being("Ooze", 3, 2, false);
    }
    else if(currentFloor >= 21 && currentFloor <= 24){
       if(randomVal < 20){
         encounter[0] = new Being("Wizard", 1, randomThreeLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 20){
         encounter[0] = new Being("Wizard", 2, randomThreeLvl, false);
      }
      else if(randomVal < 40 && randomVal >= 60){
         encounter[0] = new Being("Wizard", 3, randomThreeLvl, false);
      }
      else if(randomVal < 60 && randomVal >= 80){
         encounter[0] = new Being("Demon", 3, randomThreeLvl, false);
      }
      else{
         encounter[0] = new Being("Demon", 2, randomThreeLvl, false);
      }
      
      if(randomVal1 < 20){
         encounter[1] = new Being("Wizard", 1, randomThreeLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 20){
         encounter[1] = new Being("Wizard", 2, randomThreeLvl2, false);
      }
      else if(randomVal1 < 40 && randomVal1 >= 60){
         encounter[1] = new Being("Wizard", 3, randomThreeLvl2, false);
      }
      else if(randomVal1 < 60 && randomVal1 >= 80){
         encounter[1] = new Being("Demon", 3, randomThreeLvl2, false);
      }
      else{
         encounter[1] = new Being("Demon", 2, randomThreeLvl2, false);
      }
      
      if(randomVal2 < 20){
         encounter[2] = new Being("Wizard", 1, randomThreeLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 20){
         encounter[2] = new Being("Wizard", 2, randomThreeLvl3, false);
      }
      else if(randomVal2 < 40 && randomVal2 >= 60){
         encounter[2] = new Being("Wizard", 3, randomThreeLvl3, false);
      }
      else if(randomVal2 < 60 && randomVal2 >= 80){
         encounter[2] = new Being("Demon", 2, randomThreeLvl3, false);
      }
      else{
         encounter[2] = new Being("Skeleton", 3, randomThreeLvl3, false);
      }
    }
    else if(currentFloor == 25){
      encounter[1] = new Being("Hawk", 2, 3, false);
    }
    
  }
  else{  // Disco Destiny generation patterns are the original difficulty - how the game was meant to be played
    if(currentFloor == 1){
      encounter[0] = new Being("Ooze", 1, 1, false);
    }
    else if(currentFloor == 2){
      encounter[0] = new Being("Ooze", 1, 1, false);
      encounter[1] = new Being("Ooze", 1, 1, false);
    }
    else if(currentFloor == 3){
      if(randomVal > 50){
        encounter[0] = new Being("Ooze", 1, 1, false);
      }
      else{
        encounter[0] = new Being("Leoger", 1, 1, false);
      }
      if(randomVal1 > 50){
        encounter[1] = new Being("Ooze", 1, 1, false);
      }
      else{
        encounter[1] = new Being("Leoger", 1, 1, false);
      }
      
    }
    else if(currentFloor == 4){  // Chooses between two
      if(randomVal > 50){
        encounter[0] = new Being("Ooze", 1, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Leoger", 1, randomTwoLvl, false);
      }
      if(randomVal1 > 50){
        encounter[1] = new Being("Ooze", 1, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Leoger", 1, randomTwoLvl2, false);
      }
      if(randomVal1 > 50){
        encounter[2] = new Being("Ooze", 1, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Leoger", 1, randomTwoLvl3, false);
      }
    }
    else if(currentFloor == 5){  // Chooses between 4
      if(randomVal > 75){
        encounter[0] = new Being("Ooze", 1, randomTwoLvl, false);
      }
      else if(randomVal > 50 && randomVal <= 75){
        encounter[0] = new Being("Ooze", 2, randomTwoLvl, false);
      }
      else if(randomVal > 25 && randomVal <= 50){
        encounter[0] = new Being("Leoger", 1, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Leoger", 2, randomTwoLvl, false);
      }
      
      if(randomVal1 > 75){
        encounter[1] = new Being("Ooze", 1, randomTwoLvl2, false);
      }
      else if(randomVal1 > 50 && randomVal1 <= 75){
        encounter[1] = new Being("Ooze", 2, randomTwoLvl2, false);
      }
      else if(randomVal1 > 25 && randomVal1 <= 50){
        encounter[1] = new Being("Leoger", 1, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Leoger", 2, randomTwoLvl2, false);
      }
      
      if(randomVal2 > 75){
        encounter[2] = new Being("Ooze", 1, randomTwoLvl3, false);
      }
      else if(randomVal2 > 50 && randomVal2 <= 75){
        encounter[2] = new Being("Ooze", 2, randomTwoLvl3, false);
      }
      else if(randomVal2 > 25 && randomVal2 <= 50){
        encounter[2] = new Being("Leoger", 1, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Leoger", 2, randomTwoLvl3, false);
      }
      
    } // End of F1 - F5
    
    else if(currentFloor == 6){  // Picks from 3
      if(randomVal > 66){
        encounter[0] = new Being("Skeleton", 1, 1, false);
      }
      else if(randomVal > 33 && randomVal <= 66){
        encounter[0] = new Being("Ooze", 2, 1, false);
      }
      else{
        encounter[0] = new Being("Leoger", 2, 1, false);
      }
      if(randomVal1 > 66){
        encounter[1] = new Being("Skeleton", 1, 1, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[1] = new Being("Ooze", 2, 1, false);
      }
      else{
        encounter[1] = new Being("Leoger", 2, 1, false);
      }
      
    }
    else if(currentFloor == 7){
      if(randomVal > 50){
        encounter[0] = new Being("Skeleton", 1, 1, false);
      }
      else{
        encounter[0] = new Being("Ooze", 2, randomTwoLvl, false);
      }
      if(randomVal1 > 50){
        encounter[0] = new Being("Skeleton", 1, 1, false);
      }
      else{
        encounter[0] = new Being("Ooze", 2, randomTwoLvl2, false);
      }
      
    }
    else if(currentFloor == 8){
      if(randomVal > 75){
        encounter[0] = new Being("Skeleton", 1, randomTwoLvl, false);
      }
      else if(randomVal > 50 && randomVal <= 75){
        encounter[0] = new Being("Skeleton", 2, randomTwoLvl, false);
      }
      else if(randomVal > 25 && randomVal <= 50){
        encounter[0] = new Being("Ooze", 2, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Leoger", 2, randomTwoLvl, false);
      }
      
      if(randomVal1 > 75){
        encounter[1] = new Being("Skeleton", 1, randomTwoLvl2, false);
      }
      else if(randomVal1 > 50 && randomVal1 <= 75){
        encounter[1] = new Being("Skeleton", 2, randomTwoLvl2, false);
      }
      else if(randomVal1 > 25 && randomVal1 <= 50){
        encounter[1] = new Being("Ooze", 2, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Leoger", 2, randomTwoLvl2, false);
      }
      
      if(randomVal2 > 75){
        encounter[2] = new Being("Skeleton", 1, randomTwoLvl3, false);
      }
      else if(randomVal2 > 50 && randomVal2 <= 75){
        encounter[2] = new Being("Skeleton", 2, randomTwoLvl3, false);
      }
      else if(randomVal2 > 25 && randomVal2 <= 50){
        encounter[2] = new Being("Ooze", 2, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Leoger", 2, randomTwoLvl3, false);
      }
      
    }
    else if(currentFloor == 9){
      if(randomVal > 66){
        encounter[0] = new Being("Skeleton", 1, randomTwoLvl, false); // LVL
      }
      else if(randomVal > 33 && randomVal <= 66){
        encounter[0] = new Being("Ooze", 3, 1, false);
      }
      else{
        encounter[0] = new Being("Demon", 1, 1, false);
      }
      if(randomVal1 > 66){
        encounter[1] = new Being("Skeleton", 1, randomTwoLvl2, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[1] = new Being("Ooze", 3, 1, false);
      }
      else{
        encounter[1] = new Being("Demon", 1, 1, false);
      }
      
    }
    else if(currentFloor == 10){
      encounter[0] = new Being("Ooze", 1, 2, false);  // The Ooze floor :D
      encounter[1] = new Being("Ooze", 2, 2, false);
      encounter[2] = new Being("Ooze", 3, 1, false);
    } // End of F6 - F10
    
    else if(currentFloor == 11){
       if(randomVal > 66){
        encounter[0] = new Being("Skeleton", 1, randomTwoLvl, false);
      }
      else if(randomVal > 33 && randomVal <= 66){
        encounter[0] = new Being("Skeleton", 2, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Leoger", 3, randomTwoLvl, false);
      }
      if(randomVal1 > 66){
        encounter[1] = new Being("Skeleton", 1, randomTwoLvl2, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[1] = new Being("Skeleton", 2, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Leoger", 3, randomTwoLvl2, false);
      }
      if(randomVal2 > 66){
        encounter[2] = new Being("Skeleton", 1, randomTwoLvl3, false);
      }
      else if(randomVal2 > 33 && randomVal2 <= 66){
        encounter[2] = new Being("Skeleton", 2, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Leoger", 3, randomTwoLvl3, false);
      }
      
    }
    else if(currentFloor == 12){
      if(randomVal > 66){
        encounter[0] = new Being("Skeleton", 1, 1, false);
      }
      else if(randomVal > 33 && randomVal <= 66){
        encounter[0] = new Being("Skeleton", 2, 1, false);
      }
      else{
        encounter[0] = new Being("Demon", 1, 1, false);
      }
      if(randomVal1 > 66){
        encounter[1] = new Being("Skeleton", 1, 1, false);
      }
      else if(randomVal1 > 33 && randomVal1 <= 66){
        encounter[1] = new Being("Skeleton", 2, 1, false);
      }
      else{
        encounter[1] = new Being("Demon", 1, 1, false);
      }
    }
    else if(currentFloor == 13 || currentFloor == 14){
      if(randomVal > 75){
        encounter[0] = new Being("Wizard", 1, randomTwoLvl, false);
      }
      else if(randomVal > 50 && randomVal <= 75){
        encounter[0] = new Being("Ooze", 3, randomTwoLvl, false);
      }
      else if(randomVal > 25 && randomVal <= 50){
        encounter[0] = new Being("Demon", 1, randomTwoLvl, false);
      }
      else{
        encounter[0] = new Being("Demon", 2, randomTwoLvl, false);
      }
      
      if(randomVal1 > 75){
        encounter[1] = new Being("Wizard", 1, randomTwoLvl2, false);
      }
      else if(randomVal1 > 50 && randomVal1 <= 75){
        encounter[1] = new Being("Ooze", 3, randomTwoLvl2, false);
      }
      else if(randomVal1 > 25 && randomVal1 <= 50){
        encounter[1] = new Being("Demon", 1, randomTwoLvl2, false);
      }
      else{
        encounter[1] = new Being("Demon", 2, randomTwoLvl2, false);
      }
      
      if(randomVal2 > 75){
        encounter[2] = new Being("Wizard", 1, randomTwoLvl3, false);
      }
      else if(randomVal2 > 50 && randomVal2 <= 75){
        encounter[2] = new Being("Ooze", 3, randomTwoLvl3, false);
      }
      else if(randomVal2 > 25 && randomVal2 <= 50){
        encounter[2] = new Being("Demon", 1, randomTwoLvl3, false);
      }
      else{
        encounter[2] = new Being("Skeleton", 2, randomTwoLvl3, false);
      }
    }
    else if(currentFloor == 15){
      encounter[1] = new Being("Hawk", 1, 3, false);
    }
  }
  
  return encounter;
}

void currentBG(int currentFloor){  // A method that draws the background corresponding to the floor the player is on
  PImage current;
  String location;
  currentFloor = currentFloor + 1;
  if(inferno){  // Disco Inferno BGs
    // BG for L1 - L5
    if(currentFloor <= 5){
      current = gameBackgrounds[0];
      location = "Halls of Hate";
    }
    // BG for L6 - L10
    else if(currentFloor > 5 && currentFloor <= 10){
      current = gameBackgrounds[1];
      location = "Haunted Halls of Hate";
    }
    // BG for L11 - L15
    else if(currentFloor > 10 && currentFloor <= 15){
      current = gameBackgrounds[2];
      location = "Ballrooms of Battle";
    }
    // BG for L16 - L20
    else if(currentFloor > 15 && currentFloor <= 20){
      current = gameBackgrounds[3];
      location = "Belligerent Ballrooms of Battle";
    }
    // BG for L21 - L25
    else if(currentFloor > 20 && currentFloor <= 24){
      current = gameBackgrounds[5];
      location = "Treacherous Terraces of Terror";
    }
    else{
      current = gameBackgrounds[7];
      location = "Highest Note of the Fortress of Funk, at the Dance Floor of Destiny";
    }
    
  }
  else{  // Disco Destiny BGs
    // BG for L1 - L5
    if(currentFloor <= 5){
      current = gameBackgrounds[0];
      location = "Halls of Hate";
    }
    // BG for L6 - L10
    else if(currentFloor > 5 && currentFloor <= 10){
      current = gameBackgrounds[2];
      location = "Ballrooms of Battle";
    }
    // BG for L11 - L15
    else if(currentFloor > 10 && currentFloor <= 14){
      current = gameBackgrounds[4];
      location = "Terraces of Terror";
    }
    else{
      current = gameBackgrounds[6];
      location = "Highest Note of the Fortress of Funk, at the Dance Floor of Destiny";
    }
  }
  textSize(24);
  fill(255);
  image(current, 0, 0);
  text(location + " | L" + (currentFloor), 10, 25);
}

void mainMenu(){  // Method for drawing all main menu buttons
    textSize(48);
    Button start = new Button(260, 300, 200, 80, menuButtonBoxes[0], "Start");
    Button destiny = new Button(20, 400, 320, 80, menuButtonBoxes[1], "Disco Destiny");
    Button infern = new Button(380, 400, 320, 80, menuButtonBoxes[2], "Disco Inferno");
    Button quit = new Button(260, 500, 200, 80, menuButtonBoxes[3], "Quit");
  
    start.drawButton();
    destiny.drawButton();
    infern.drawButton();
    quit.drawButton();
  
    if(start.pressed()){
      text("Loading...", 500, 750);
      sound6.play();
      state = 1;
    }
    if(destiny.pressed()){
       sound6.play();
       inferno = false;
    }
    if(infern.pressed()){
      sound6.play();
      inferno = true;
    }
    if(quit.pressed()){
      exit();
    }
    
    textSize(18);
    textAlign(CENTER);
    text("A game by Andrew Kohler", width/2, 780);
}


void playerAction(Being player){  // Method for drawing all action buttons; returns the player's selection
  textSize(24);
  allowPress();
  
  if(player.actionList[0] == 1){  // If the player can [ATTACK], then create a button for that option
    textSize(24); 
    Button attack = new Button(30, 650, 200, 50, menuButtonBoxes[4], "ATTACK");
    attack.drawButton();
    if(attack.pressed() && load){
      chosenAction = 0;

    }
  }
  if(player.actionList[1] == 1){  // [HEAL]
    textSize(20);
    Button heal = new Button(250, 650, 200, 50, menuButtonBoxes[4], "HEAL (3 GRV)");
    heal.drawButton();
    if(heal.pressed() && load){
      if(player.GRV >= 3){
        chosenAction = 1;
        turnOrder[myTurn].changeGRV(-3);
      }
      else{
        flavorText = player.name + " doesn't have enough groove for that!";
      }
    }
  }
  if(player.actionList[2] == 1){ // [REVIVE]
    textSize(20);
    Button rev = new Button(30, 700, 200, 50, menuButtonBoxes[4], "REVIVE (7 GRV)");  // I think this is the only one I NEED an additional check on; you CANNOT attempt a revive if all allies are up
    rev.drawButton();
    if(rev.pressed() && load){
      if(player.GRV >= 7){
        if(allyDown(turnOrder)){
          chosenAction = 2;
          turnOrder[myTurn].changeGRV(-7);
        }
        else{
          flavorText = "All members of your party are in top form!";
        }
        
      }
      else{
        flavorText = player.name + " doesn't have enough groove for that!";
      }
    }
  }
  if(player.actionList[3] == 1){ // [GRV UP]
    textSize(18);
    Button grv = new Button(250, 700, 200, 50, menuButtonBoxes[4], "GROOVE UP (2 GRV)");
    grv.drawButton();
    if(grv.pressed() && load){
      if(player.GRV >= 2){
        chosenAction = 3;
        turnOrder[myTurn].changeGRV(-2);
      }
      else{
        flavorText = player.name + " doesn't have enough groove for that!";
      }
    }
  }
  if(player.actionList[4] == 1){ // [BEAT STOP]
    textSize(18);
    Button beat = new Button(30, 750, 200, 50, menuButtonBoxes[4], "BEAT STOP (5 GRV)");
    beat.drawButton();
    if(beat.pressed() && load){
      if(player.GRV >= 5){
        chosenAction = 4;
        turnOrder[myTurn].changeGRV(-5);
      }
      else{
        flavorText = player.name + " doesn't have enough groove for that!";
      }
    }
  }
  if(player.actionList[5] == 1){ // [RECRUIT]
    textSize(20);
    Button recruit = new Button(250, 750, 200, 50, menuButtonBoxes[4], "RECRUIT (3 GRV)");
    recruit.drawButton();
    if(recruit.pressed() && load){
      if(player.GRV >= 3){
        chosenAction = 5;
        turnOrder[myTurn].changeGRV(-3);
      }
      else{
        flavorText = player.name + " doesn't have enough groove for that!";
      }
    }
  }
 
}

void playerTarget(int type, Being[] turnTakers){  // Creates targeting buttons relevant to the selected action
  Button[] buttons = new Button[3];
  int[] index = new int[3];
  int count = 0;
  int buttonX = 130;
  int buttonY = 650;
  textSize(14);
  
  if(type == 0){  // We're attacking; bring up buttons with all non-downed enemies
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        
        if(!turnTakers[i].ally && !turnTakers[i].down){
          buttons[count] = new Button(buttonX, buttonY, 200, 50, menuButtonBoxes[5], turnTakers[i].name);
          index[count] = i;
          buttons[count].drawButton();
          count++;
          buttonY += 50;
          
        }
        
      }
    }
  } // End of attack
  
  else if(type == 1){  // We're healing; bring up buttons with all non-downed allies 
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        
        if(turnTakers[i].ally && !turnTakers[i].down){
          buttons[count] = new Button(buttonX, buttonY, 200, 50, menuButtonBoxes[5], turnTakers[i].name);
          index[count] = i;
          buttons[count].drawButton();
          count++;
          buttonY += 50;
          
        }
        
      }
    }
  } // End of heal
  
  else if(type == 2){  // We're reviving; bring up buttons with all downed allies
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        
        if(turnTakers[i].ally && turnTakers[i].down){
          buttons[count] = new Button(buttonX, buttonY, 200, 50, menuButtonBoxes[5], turnTakers[i].name);
          index[count] = i;
          buttons[count].drawButton();
          count++;
          buttonY += 50;
          
        }
        
      }
    }
  } // End of revive
  
  else if(type == 3){  // We're groove upping; bring up buttons with all allies 
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        
        if(turnTakers[i].ally){
          buttons[count] = new Button(buttonX, buttonY, 200, 50, menuButtonBoxes[5], turnTakers[i].name);
          index[count] = i;
          buttons[count].drawButton();
          count++;
          buttonY += 50;
          
        }
        
      }
    }
  } // End of groove
  
  else if(type == 4){  // We're beat stopping; bring up buttons with all enemies 
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        
        if(!turnTakers[i].ally){
          buttons[count] = new Button(buttonX, buttonY, 200, 50, menuButtonBoxes[5], turnTakers[i].name);
          index[count] = i;
          buttons[count].drawButton();
          count++;
          buttonY += 50;
          
        }
        
      }
    }
  } // End of beat stop
  
  else if(type == 5){  // We're recruiting; bring up buttons with all enemies
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        
        if(!turnTakers[i].ally){
          buttons[count] = new Button(buttonX, buttonY, 200, 50, menuButtonBoxes[5], turnTakers[i].name);
          index[count] = i;
          buttons[count].drawButton();
          count++;
          buttonY += 50;
          
        }
        
      }
    }
  } // End of recruit
   
  allowPressTwo();
  
  if(load2){
    if(buttons[0].pressed()){
      targetIndex = index[0];
    }
    else if(buttons[1] != null){
      if(buttons[1].pressed()){
        targetIndex = index[1];
      } 
    }
    else if(buttons[2] != null){
      if(buttons[2].pressed()){
        targetIndex = index[2];
      } 
     }
  }
  
}

void act(int type, Being actor, int targetIndex){  // Uses the actor's stats to perform an action on the target
  if(type == 0){  // We're attacking
    int chance = (int)(random(0, 100));  // Roll for a crit chance
    if(chance <= 5){  // Double damage
      flavorText = actor.name + " boogies down at " + turnOrder[targetIndex].name + "! " + (actor.ATK*2) + " damage!!";
      turnOrder[targetIndex].changeHP(-actor.ATK*2);
    }
    else{
      flavorText = actor.name + " busts a move at " + turnOrder[targetIndex].name + "! " + (actor.ATK) + " damage!";
      turnOrder[targetIndex].changeHP(-actor.ATK);
    }
    
  }
  else if(type == 1){  // We're healing; use the actor's level * 4
    int chance = (int)(random(0, 100));  // Roll for a crit chance
    if(chance <= 5){  // Double healing
      flavorText = actor.name + " shows " + turnOrder[targetIndex].name + " the meaning of disco! " + (actor.LVL * 8) + " healed!";
      turnOrder[targetIndex].changeHP(actor.LVL * 8);
      turnOrder[targetIndex].beatStop(false);
    }
    else{
      flavorText = actor.name + " gets " + turnOrder[targetIndex].name + " back on the beat! " + (actor.LVL * 4) + " healed!";
      turnOrder[targetIndex].changeHP(actor.LVL*4);
      turnOrder[targetIndex].beatStop(false);
    }
    
  }
  else if(type == 2){  // We're reviving
    flavorText = actor.name + " pulls " + turnOrder[targetIndex].name + " back to the dance floor! Full heal!";
    turnOrder[targetIndex].changeHP(turnOrder[targetIndex].maxHP);
  }
  
  else if(type == 3){  // We're groove upping; use the actor's level * 5
    int chance = (int)(random(0, 100));  // Roll for a crit chance
    if(chance <= 5){  // Double damage
      flavorText = actor.name + " and " + turnOrder[targetIndex].name + " do the YMCA together! " + (actor.LVL*10) + " groove up!!";
      turnOrder[targetIndex].changeGRV(actor.LVL*10);
    }
    else{
      flavorText = actor.name + " teaches " + turnOrder[targetIndex].name + " a new dance move! " + (actor.LVL * 5) + " groove up!";
      turnOrder[targetIndex].changeGRV(actor.LVL * 5);
    }
    
  }
  else if(type == 4){  // We're beat stopping
  int chance = (int)(random(0, 100));  // Roll for chance to hit or miss
    if(chance == 99){
      flavorText = actor.name + " accidently loses the beat!";
      turnOrder[myTurn].beatStop(true);
    }
    else if(chance == 98){
      flavorText = actor.name + " turns off the music! EVERYONE IS BEAT-STOPPED!";
      for(int i = 0; i < turnOrder.length; i++){
        turnOrder[i].beatStop(true);
      }
    }
    else if(chance <= actor.LVL * 10 + 25){  // Chance to hit
      flavorText = actor.name + " stops the beat for " + turnOrder[targetIndex].name + "!";
      turnOrder[targetIndex].beatStop(true);
    }
    else{
      flavorText = actor.name + " just can't stop the beat!";
    }
    
  }
  else if(type == 5){  // We're recruiting
    if(turnOrder[targetIndex].name == "Disco Bird"){
      flavorText = "Disco Bird's heart is like a disco ball, and reflects the evil suggestion away!";
    }
    else if(turnOrder[targetIndex].name == "The Hawk of Hate"){
      flavorText = "The Hawk of Hate laughs, and boogies on! He gains +1 ATK!";
      turnOrder[targetIndex].changeATK(1);
    }
    else if(turnOrder[targetIndex].name == "The Heinous Hawk of Hate"){
      flavorText = "The Heinous Hawk of Hate is filled with hatred at your attempt! He gains +2 ATK!";
      turnOrder[targetIndex].changeATK(2);
    }
    else{
      if(turnOrder[targetIndex].down){    // Prevents recruitment of downed Beings
        if(turnOrder[targetIndex].ally){
          flavorText = turnOrder[targetIndex].name + " is down and can't see the enemy dance moves!";
        }
        else{
          flavorText = turnOrder[targetIndex].name + " is down and can't see your dance moves!";
        }
      }
      else{
        boolean prev = turnOrder[targetIndex].ally;
      turnOrder[targetIndex].changeRecruit(); // Alter the target's recruit value

      if(turnOrder[targetIndex].recruitDifficulty == 2 && prev == turnOrder[targetIndex].ally){  // Set flavor text for unsuccessful recruits
        if(turnOrder[targetIndex].ally){
          flavorText = turnOrder[targetIndex].name + " is busting moves, but they seem interested in the enemy team...";
        }
        else{
          flavorText = turnOrder[targetIndex].name + " is busting moves, but they seem interested in your team...";
        }
      }
      else if(turnOrder[targetIndex].recruitDifficulty == 1 && prev == turnOrder[targetIndex].ally){
        if(turnOrder[targetIndex].ally){
          flavorText = turnOrder[targetIndex].name + " looks interested in joining the enemy team...";
        }
        else{
          flavorText = turnOrder[targetIndex].name + " looks interested in joining your team...";
        }
      }
      else if(turnOrder[targetIndex].ally != prev){
        if(turnOrder[targetIndex].ally){
          flavorText = turnOrder[targetIndex].name + " is swayed by your dance moves, and joins your team!";
        }
        else{
          flavorText = turnOrder[targetIndex].name + "is mesmerized by the enemy dance moves, and joins their team!";
        }
        
        int minHP = 1000;
          int minHPIndex = -1;
          int count = 0;
        
        if(actor.ally){  // If the actor is an ally, we need to switch the target from the ENEMY team to the ALLY team
          
          for(int i = 0; i < turnOrder.length; i++){  // Check for lowest HP being aligned with the caster's "ally" boolean, get their index
            if(turnOrder[i] != null){
              if(turnOrder[i].ally && turnOrder[i] != turnOrder[myTurn]){
               count++; 
               if(turnOrder[i].HP < minHP && turnOrder[i].name != "Disco Bird"){
                 minHP = turnOrder[i].HP;
                 minHPIndex = i;
               }
              }
            }
          }
          if(count == 3){  // If we have 3 allies, replace the one with the lowest HP
            // Set the ally we are replacing equivalent to their replacement
            turnOrder[minHPIndex] = turnOrder[targetIndex];
            // Set the replacement's original position to null
            turnOrder[targetIndex] = null;
          }
          // Otherwise, the game will sort of just run as intended, which is cool
          
        }
        else{ // If the actor is an enemy, the opposite is true
        for(int i = 0; i < turnOrder.length; i++){  // Check for lowest HP being aligned with the caster's "ally" boolean, get their index
            if(turnOrder[i] != null){
              if(!turnOrder[i].ally && turnOrder[i] != turnOrder[myTurn]){
               count++; 
               if(turnOrder[i].HP < minHP){
                 minHP = turnOrder[i].HP;
                 minHPIndex = i;
               }
              }
            }
          }
          if(count == 3){  // If we have 3 allies, replace the one with the lowest HP
            // Set the ally we are replacing equivalent to their replacement
            turnOrder[minHPIndex] = null;
            turnOrder[minHPIndex] = turnOrder[targetIndex];
            // Set the replacement's original position to null
            turnOrder[targetIndex] = null;
          }
          
        }
      }
      }
      
      
    }
    
  }
}

void drawAllyStats(Being[] turnTakers){  // Method for drawing ally stats
  int textX = 517;
  int textY = 685;
  image(menuButtonBoxes[6], 500, 660);
  
  textSize(14);
  fill(0, 0, 0);
  for(int i = 0; i < turnTakers.length; i++){
    if(turnTakers[i] != null && turnTakers[i].ally){  // If the given element is an ally
      text(turnTakers[i].name + " , LVL" + turnTakers[i].LVL, textX, textY);
      textY += 15;
      text("HP: " + turnTakers[i].HP + "/" + turnTakers[i].maxHP + " GRV: " + turnTakers[i].GRV + "/" + turnTakers[i].maxGRV + " XP: " + turnTakers[i].XP + "/" + turnTakers[i].threshold, textX, textY);
      textY += 15;
      
    }
  }

}

void turnOrderCalc(Being[] turnTakers){  // Calculates the order in which turns should be taken on the current floor based on speed values
  int[] speedList = new int[6];  // Set up a list of SPD values
  for(int i = 0; i < turnTakers.length; i++){    // Put every relevant SPD value in an array
    if(turnTakers[i] != null){
      speedList[i] = turnTakers[i].SPD;
    }
    else{
     speedList[i] = 0; 
    }
  }
  
  speedList = sort(speedList);    
  
  int count = 0;
  for(int j = speedList.length - 1; j >= 0; j--){    // For each element of the sorted array (moving backwards because higher speeds take priority)
  
    if(speedList[j] != 0){  // Ignoring null values
      for(int k = 0; k < turnTakers.length; k++){  // Search for a corresponding value in the list of beings
        if(turnTakers[k] != null){
          if(turnTakers[k].SPD == speedList[j]){  // If a corresponding speed value is found, add that being to the list in the proper spot
          turnOrder[count] = turnTakers[k];     // Remove it from the original list to avoid dupes
          turnTakers[k] = null;
          count++;
          break;
          } 
        }
        
        
      }
    }
  }

}

void redrawBeings(Being[] turnTakers, int allyXMod, int allyYMod, int enemyXMod){  // A method for redrawing beings whenever relevant (e.g. after a recruit occurs); also draws indicators for current turn taker and actions
  int allyX = 120;
  int allyY = 160;
  int enemyX = 480;
  int enemyY = 160;
  int FXModY = 0;

    for(int i = 0; i < turnTakers.length; i++){  // For each element of turnOrder
      if(turnTakers[i] != null){
        if(turnTakers[i].classification == "Ooze" || turnTakers[i].classification == "Bird"){
          FXModY = -20;
        }
        else{
         FXModY = -85;
        }

        if(turnTakers[i].ally){ // if an ally, draw on ally side at proper pos
          if(turnTakers[i].name == "Disco Bird"){
            if(i == myTurn){
              image(turnTakers[i].currentSprite, allyX + 30 + allyXMod, allyY + allyYMod);
              
              if(chosenAction != -1 && targetIndex != -1){  // Displays turn indicators or battle effects over the Being's head
                if(chosenAction == 5){
                  image(battleFX[3], allyX + 80, allyY + FXModY);
                }
                else{
                  image(battleFX[chosenAction], allyX + 80, allyY + FXModY);
                }
              }
              else{
                image(battleFX[6], allyX + 80, allyY + FXModY);
              }
              
            }
            else{
              image(turnTakers[i].currentSprite, allyX + allyXMod, allyY + allyYMod);
            }
            
          }
          else{
            pushMatrix();
            scale(-1, 1);
            if(i == myTurn){
              image(turnTakers[i].currentSprite, -allyX - allyX - 30 - allyXMod, allyY);  
               scale(-1,1);
               if(chosenAction != -1 && targetIndex != -1){  // Displays turn indicators or battle effects over the Being's head
                if(chosenAction == 5){
                  image(battleFX[3], allyX + 30, allyY + FXModY);
                }
                else{
                  image(battleFX[chosenAction], allyX + 30, allyY + FXModY);
                }
              }
              else{
                image(battleFX[6], allyX + 30, allyY + FXModY);
              }
              
              
            }
            else{
              image(turnTakers[i].currentSprite, -allyX - allyX - allyXMod, allyY + allyYMod);
            }
            popMatrix();
           }
            
            allyX -= 10;
            allyY += 90;
          } // End of ally checks
          
          else{ // if an enemy, draw on enemy side at proper pos
            if(i == myTurn){
              image(turnTakers[i].currentSprite, enemyX - 30 - allyXMod, enemyY);
               if(chosenAction != -1 && targetIndex != -1){  // Displays turn indicators or battle effects over the Being's head
                  if(chosenAction == 5){
                    image(battleFX[3], enemyX, enemyY + FXModY);
                  }
                  else{
                    image(battleFX[chosenAction], enemyX, enemyY + FXModY);
                  }
                }
                else{
                  image(battleFX[6], enemyX, enemyY + FXModY);
                }
                
            }
            else{
              image(turnTakers[i].currentSprite, enemyX - enemyXMod, enemyY);
            }
            
            enemyX += 10;
            enemyY += 90;
        
          } // End of enemy checks
          
          
        } // End of null checks
       
        
    } // End of for loop
    
} // End of function

void endingDraw(Being[] beings, boolean victory){  // Draws the party on the victory or defeat screen; true is victory, false is defeat
  int x = 120;
  int y = 300;
  int count = 0;
  for(int i = 0; i < beings.length; i++){
    if(beings[i] != null){
      if(beings[i].ally){
        if(count == 0){
         x = 280; 
        }
        else if(count == 1){
         x = 120; 
        }
        else if(count == 2){
         x = 440; 
        }
        
        if(victory){
          image(beings[i].sprite[5], x, y);
        }
        else{
          image(beings[i].sprite[3], x, y);
        }
        count++; 
        }
    }
  }  
}


boolean allyDown(Being[] turnTakers){  // Function for checking if at least one ally is dead (for revives)
  boolean down = false;
  for(int i = 0; i < turnTakers.length; i++){
    if(turnTakers[i] != null){
      if(turnTakers[i].ally && turnTakers[i].down){
       down = true; 
      }
    }
  }
  return down;
}

boolean allAlliesDown(Being[] turnTakers){ // Function for checking if all allies are dead (for game overs); returns true if all allies are down
  boolean down = true;
  for(int i = 0; i < turnTakers.length; i++){
    if(turnTakers[i] != null){
      if(turnTakers[i].ally && !turnTakers[i].down){
       down = false; 
      }
    }
  }
  return down;
}

boolean allEnemiesDown(Being[] turnTakers){ // Function for checking if all enemies are dead (for victories); returns true if all enemies are down
  boolean down = true;
  for(int i = 0; i < turnTakers.length; i++){
    if(turnTakers[i] != null){
      if(!turnTakers[i].ally && !turnTakers[i].down){
       down = false; 
      }
    }
  }
  return down;
}

void allowPress(){                // Prevents clicking on a target button from activating an action button
  if(!mousePressed && check){
    check = false;
    load = true;
  }
  else if(mousePressed && check){
   load = false; 
  }  
}

void allowPressTwo(){                // Prevents clicking on an action button from activating a target button
  if(!mousePressed && check2){
    check2 = false;
    load2 = true;
  }
  else if(mousePressed && check2){
   load2 = false; 
  }  
}
