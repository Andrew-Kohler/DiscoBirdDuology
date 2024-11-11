class Being{
  int HP;  // How much health a Being has
  int maxHP;  // Max health of a being
  int ATK; // How much damage a Being's attacks do
  int SPD; // How fast a Being is
  int GRV; // How much Groove Energy a being has75
  int maxGRV; // Max Groove Energy of a Being
  int recruitDifficulty;  // How difficult it is to initially recruit a Being
  int LVL;  // A Being's level
  int XP;   // The amount of experience points a Being has
  int XPYield;  // How much XP a monster gives if defeated
  int threshold;  // How much XP needed to LVL UP
  
  boolean down;    // Whether a Being is downed (0 HP)
  boolean stopped; // Whether a Being is beat-stopped (cannot act)
  boolean ally;    // Whether a Being is an ally or an emeny 
  
  String classification;  // A Being's class, used exclusively to determine where battle FX should go above their sprite
  String name;  // A Being's name
  int[] actionList; // A list of the actions a being is capable of: 0 = Attack, 1 = Heal, 2 = Revive, 3 = Groove Up, 4 = Beat Stop, 5 = Recruit
  
  PImage[] sprite;  // An array of a being's different sprites: 0 = Standing, 1 = Attacking, 2 = Taking Damage, 3 = Downed, 4 = Beat-Stopped, 5 = Victory
  PImage currentSprite;  // The current display sprite of a being
  
  int[][] lvlData;  // Stores all the stats associated with a being's level 1, 2, and 3
  
  Being(String beingClass, int beingSubclass, int beingLVL, boolean friend){  // An all-encompassing constructor
   // Being CLASS: Bird, Hawk, Ooze, Leoger, Skeleton, Demon, Wizard
   // Being SUBLCASS: What variant of the class the being is (e.g. Wizards can be Warring, Wicked, or Wumbulous - 1, 2, or 3)
   // Being LEVEL: What level the being is (Determines its initial stats)
   // Friend: Determines initial allegience
   
    actionList = new int[6];  // Set up arrays
    sprite = new PImage[6];    
    lvlData = new int[3][15];  
    
    classification = beingClass;
    String fileName = beingClass + beingSubclass;                // Load all stats into the being
    String[] lines = loadStrings("Stats/" + fileName + ".txt");
    
    int k = 0;                      // Compiles ALL stats for future use
    for(int i = 0; i < 3; i++){
     for(int j = 0; j < 15; j++){
      lvlData[i][j] =  Integer.valueOf(lines[k]);
      k++;
     }
    }
    
    if(beingLVL == 1){  // Re-using k for a different purpose
      k = 0;
    }
    else if(beingLVL == 2){
      k = 1;
    }
    else if(beingLVL == 3){
      k = 2;
    }
    HP = lvlData[k][0];
    maxHP = lvlData[k][1];
    ATK = lvlData[k][2];
    SPD = lvlData[k][3];
    GRV = lvlData[k][4];
    maxGRV = lvlData[k][5];
    recruitDifficulty = lvlData[k][6];
    LVL = beingLVL;
    XP = 0;
    XPYield = lvlData[k][7];
    threshold = lvlData[k][8];
    down = false;
    stopped = false;
    ally = friend;
    actionList[0] = lvlData[k][9];
    actionList[1] = lvlData[k][10];
    actionList[2] = lvlData[k][11];
    actionList[3] = lvlData[k][12];
    actionList[4] = lvlData[k][13];
    actionList[5] = lvlData[k][14];

    if(beingClass == "Bird"){  // Disco Bird has a much larger sprite variety than other enemies
      sprite[0] = loadImage(beingClass + "/DiscoBird1.png");
      sprite[1] = loadImage(beingClass + "/DiscoBird2.png");
      sprite[2] = loadImage(beingClass + "/DiscoBird3.png");
      sprite[3] = loadImage(beingClass + "/DiscoBird4.png");
      sprite[4] = loadImage(beingClass + "/DiscoBird5.png");
      sprite[5] = loadImage(beingClass + "/DiscoBird6.png");
    }
    else{
      sprite[0] = loadImage(beingClass + "/" + fileName + ".png");
      sprite[1] = loadImage(beingClass + "/" + fileName + ".png");
      sprite[2] = loadImage(beingClass + "/" + fileName + ".png");
      sprite[3] = loadImage(beingClass + "/" + fileName + "D.png");
      sprite[4] = loadImage(beingClass + "/" + beingClass + "S.png");
      sprite[5] = loadImage(beingClass + "/" + fileName + ".png");
    }
    
    currentSprite = sprite[0];
    name = nameGenerator(beingClass, beingSubclass);
  }
  
  // Setter methods
  void changeHP(int num){  // Method to change a being's current HP
    currentSprite = sprite[0];
    HP += num;
    if(HP > maxHP){
     HP = maxHP; 
    }
    else if (HP <= 0){
      HP = 0;
      down = true;
      currentSprite = sprite[3];
    }
    else if(HP > 0){
      down = false;
      currentSprite = sprite[0];
    }
  }
  
  void changeMaxHP(int num){  // Change a being's max HP
    maxHP += num;
  }
  
  void changeATK(int num){  // Change a Being's ATK stat
    ATK += num; 
  }
    
  void changeSPD(int num){  // Change a Being's SPD stat
    SPD += num;  
  }
  
  void changeGRV(int num){  // Change a Being's current GRV
    GRV += num;
    if(GRV > maxGRV){
     GRV = maxGRV; 
    }
  }
  
  void changeMaxGRV(int num){  // Change a Being's max GRV
   maxGRV += num; 
  }
  
  void changeRecruit(){
    recruitDifficulty -= 1;
    if(recruitDifficulty == 0){
      ally = !ally;
      recruitDifficulty = lvlData[LVL - 1][6];
      if(ally){
       ATK += 4; 
       HP += 4;
       maxHP += 4;
      }
      if(!ally){
       ATK -= 4;
       HP -= 4;
       maxHP -= 4;
      }
    }
  }
  
  void changeXP(int num){  // Change a Being's XP (includes level up functionality)
    XP += num;
    if(XP >= threshold){
      XP = 0;
      if(LVL < 3){
        LVL += 1;
        
        HP = lvlData[LVL - 1][0];
        maxHP = lvlData[LVL - 1][1];
        ATK = lvlData[LVL - 1][2];
        SPD = lvlData[LVL - 1][3];
        maxGRV = lvlData[LVL - 1][5];
        recruitDifficulty = lvlData[LVL - 1][6];
        XP = 0;
        XPYield = lvlData[LVL - 1][7];
        threshold = lvlData[LVL - 1][8];
        down = false;
        stopped = false;
        actionList[0] = lvlData[LVL - 1][9];
        actionList[1] = lvlData[LVL - 1][10];
        actionList[2] = lvlData[LVL - 1][11];
        actionList[3] = lvlData[LVL - 1][12];
        actionList[4] = lvlData[LVL - 1][13];
        actionList[5] = lvlData[LVL - 1][14];
      }
    }
  }
  
  void beatStop(boolean val){  // Changes if a Being is beat-stopped
    stopped = val;
    if(val){
      currentSprite = sprite[4];
    }
    else{
      currentSprite = sprite[0];
    }
  }
  
  void changeSide(boolean val){  // The ally boolean determines how a Being attacks
    ally = val; 
  }
  
  int enemyAI(Being[] turnTakers){      // A decision maker for enemies based on their levels
    if(LVL >= 3){  // A level 3 enemy will first roll to see if they attempt to revive an ally, beat-stop an enemy, or try and recruit an enemy
      float r1 = random(0, 1);
      if(r1 < .2 && actionList[2] == 1 && GRV >= 7){  // Revive
        for(int i = 0; i < turnTakers.length; i++){
          if(turnTakers[i].down && !turnTakers[i].ally){  
            return 2;
          }
        } 
        
      }
      if( r1 < .2 && actionList[4] == 1 && GRV >= 5){  // Beat stop
        for(int i = 0; i < turnTakers.length; i++){
          if(!turnTakers[i].stopped && turnTakers[i].ally){  
            return 4;
          }
        }
        
      }
      if(r1 >= .2 && r1 < .4 && actionList[5] == 1 && GRV >= 3){  // Recruit
        return 5;
        
      }
      
    }
    if(LVL >= 2){  // A level 2 enemy (or a L3 enemy that did not pass checks) will first roll to see if they attempt to heal or GRV up an ally
      float r2 = random(0, 1);
      if(r2 < .6 && actionList[3] == 1 && GRV >= 2){  // Groove up
        for(int i = 0; i < turnTakers.length; i++){
          if(turnTakers[i].GRV <= turnTakers[i].maxGRV && !turnTakers[i].ally){  
            return 3;
          }
        }
        
      }
      if(r2 < .7 && actionList[1] == 1 && GRV >= 3){  // Heal
        for(int i = 0; i < turnTakers.length; i++){
          if(turnTakers[i].HP <= turnTakers[i].maxHP && !turnTakers[i].ally){  
            return 1; // This was a revive in the final submission, not sure what that will do
          }
        }
        
      }
      
    }
    // A level 1 enemy (or a L2 / L3 enemy that did not pass checks) will first roll to see if they attempt a random action, before finally falling back to attacking
    float r3 = random(0, 1);
    int r4 = (int)random(0, 5.1);
    if(r3 < .3 && actionList[r4] == 1){
      if(r4 == 1 && GRV >= 3){
        return r4;
      }
      if(r4 == 2 && GRV >= 7){
        return r4;
      }
      if(r4 == 3 && GRV >= 2){
        return r4;
      }
      if(r4 == 4 && GRV >= 5){
        return r4;
      }
      if(r4 == 5 && GRV >= 5){
        return r4;
      }
    }
    return 0;
        
  }
  
  int enemyTargetAI(int type, Being[] turnTakers){  // Allows an enemy to select a target for a chosen action; while an enemy will randomly select a target, all targets will be viable options
    int target = 0;
    int count = 0;
    int r;
    int[] options = new int[3];

    if(type == 0){  // If the enemy is attacking
      for(int i = 0; i < turnTakers.length; i++){
        if(turnTakers[i] != null){
          if(turnTakers[i].ally && !turnTakers[i].down){  // Find all non-downed allies
            options[count] = i;
            count++;
          }
          
        }
      }
      r = (int)random(0, count);
      target = options[r];
    
    }
    else if(type == 1){  // If the enemy is healing
      for(int i = 0; i < turnTakers.length; i++){
        if(turnTakers[i] != null){
          if(!turnTakers[i].ally && turnTakers[i].HP < turnTakers[i].maxHP){  // Find all injured enemies
            options[count] = i;
            count++;
          }
          
        }
      }
      r = (int)random(0, count);
      target = options[r];
      
    }
    else if(type == 2){  // If the enemy is reviving
      for(int i = 0; i < turnTakers.length; i++){
        if(turnTakers[i] != null){
          if(!turnTakers[i].ally && turnTakers[i].down){  // Find all downed enemies
            options[count] = i;
            count++;
          }
          
        }
       }
       r = (int)random(0, count);
       target = options[r];
        
    }
    else if(type == 3){  // If the enemy is GRV-upping
      for(int i = 0; i < turnTakers.length; i++){
        if(turnTakers[i] != null){
          if(!turnTakers[i].ally && turnTakers[i].GRV < turnTakers[i].maxGRV){  // Find all ungroovy enemies
            options[count] = i;
            count++;
          }
          
        }
      }
      r = (int)random(0, count);
      target = options[r];
    }
    else if(type == 4){  // If the enemy is beat-stopping
    for(int i = 0; i < turnTakers.length; i++){
      if(turnTakers[i] != null){
        if(turnTakers[i].ally && !turnTakers[i].stopped){  // Find all unstopped allies
          options[count] = i;
          count++;
        }
      }
     }
     r = (int)random(0, count);
     target = options[r];
      
    }
    else if(type == 5){  // If the enemy is recruiting
      for(int i = 0; i < turnTakers.length; i++){
        if(turnTakers[i] != null){
          if(turnTakers[i].ally && !turnTakers[i].down){  // Find all non-downed allies
            options[count] = i;
            count++;
          }
        }
      }
      r = (int)random(0, count);
      target = options[r];
    }
  
    return target;
    
  }
  
} // End of class

String nameGenerator(String beingClass, int beingSubclass){  // Gives all Beings their proper names
 String name = "";
 if(beingClass == "Ooze"){
   if(beingSubclass == 1){
     name = "Oozing Ooze";
   }
   else if(beingSubclass == 2){
     name = "Ominous Ooze";
   }
   else if(beingSubclass == 3){
     name = "Obscure Ooze";
   }
 }
 else if(beingClass == "Leoger"){
   if(beingSubclass == 1){
     name = "Lamentable Leoger";
   }
   else if(beingSubclass == 2){
     name = "Leaping Leoger";
   }
   else if(beingSubclass == 3){
     name = "Lethal Leoger";
   }
 }
 else if(beingClass == "Skeleton"){
   if(beingSubclass == 1){
     name = "Strange Skeleton";
   }
   else if(beingSubclass == 2){
     name = "Spooky Skeleton";
   }
   else if(beingSubclass == 3){
     name = "Scary Skeleton";
   }
 }
 else if(beingClass == "Demon"){
   if(beingSubclass == 1){
     name = "Demented Demon";
   }
   else if(beingSubclass == 2){
     name = "Dangerous Demon";
   }
   else if(beingSubclass == 3){
     name = "Dancing Demon";
   }
 }
 else if(beingClass == "Wizard"){
   if(beingSubclass == 1){
     name = "Warring Wizard";
   }
   else if(beingSubclass == 2){
     name = "Wicked Wizard";
   }
   else if(beingSubclass == 3){
     name = "Wumbulous Wizard";
   }
 }
 else if(beingClass == "Hawk"){
   if(beingSubclass == 1){
     name = "The Hawk of Hate";
   }
   else if(beingSubclass == 2){
     name = "The Heinous Hawk of Hate";
   }
 }
 else if(beingClass == "Bird"){
   if(beingSubclass == 1){
     name = "Disco Bird";
   }
 }
 
 return name;
}
