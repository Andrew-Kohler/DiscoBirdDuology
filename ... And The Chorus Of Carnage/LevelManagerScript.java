import java.awt.geom.Ellipse2D;
import java.util.ArrayList;

public class LevelManagerScript extends ScriptableBehavior{

    int currentLevel;
    boolean firstLoop = true;      // As we go through the 3 levels for the first time, we increase the level cap, so on subsequent loops, there's an actual difficulty increase
    int enemyLevelCap = 1;

    int startX = 25;
    int startY = 50;

    float waveWaitTimer = 1f;

    float waveWaitTime = 1f;

    GameManagerScript gm;

    // Hmm. Problem. This assumes that enemies will be removing themselves from the enemy list when they die.
    // I'll simply follow that most old and noble tradition of this project:
    // Put it in the GameManager lol

    LevelManagerScript(GameObject g, GameManagerScript gm) {
        super(g);
        this.gm = gm;
    }

    @Override
    public void Start() {

    }

    @Override
    public void Update() {
        if(gm.GetCurrentEnemyList().size() == 0 && gm.currentScene == 1){  // If there are no enemies
            if(currentLevel == 0){  // If we are starting the game, there should not be a spawn delay
                currentLevel++;
                SpawnNewLevel();
            }
            else{   // Otherwise, though, we need to wait 1 second between waves
                if(waveWaitTimer > 0){
                    waveWaitTimer -= (float)gm.delta_time/1000;
                }
                else{
                    SpawnNewLevel();
                }
            }
        }

    }

    private void SpawnNewLevel(){
        int currentX = startX;
        int currentY = startY;
        if(currentLevel == 1){
            // 2 rows of 8 L1s
            for(int i = 0; i < 2; i++){
                for(int j = 0; j < 8; j++){
                    GameObject enemy = new GameObject(currentX,currentY);
                    enemy.shape = new Ellipse2D.Float(0, 0, 50, 50);
                    //enemy.material = new Material("resources/EnemyL1.png");

                    int lvl = GenerateEnemyLevelValue();
                    enemy.scripts.add(new EnemyController(enemy, gm, lvl));
                    if(lvl == 1){
                        enemy.material = new Material("resources/EnemyL1.png");
                    }
                    else if(lvl == 2){
                        enemy.material = new Material("resources/EnemyL2.png");
                    }
                    else{
                        enemy.material = new Material("resources/EnemyL3.png");
                    }

                    GatorEngine.OBJECTLIST.add(enemy);
                    gm.AddToScene(enemy);
                    gm.AddToCurrentEnemyList(enemy);

                    currentX += 50;
                }
                currentX = startX;
                currentY += 55;
            }

            if(firstLoop){
                enemyLevelCap++;
            }
        }
        else if(currentLevel == 2){
            // 3 rows of 8 L1s and L2s
            for(int i = 0; i < 3; i++){
                for(int j = 0; j < 8; j++){
                    GameObject enemy = new GameObject(currentX,currentY);
                    enemy.shape = new Ellipse2D.Float(0, 0, 50, 50);
                    //enemy.material = new Material("resources/EnemyL1.png");

                    int lvl = GenerateEnemyLevelValue();
                    enemy.scripts.add(new EnemyController(enemy, gm, lvl));
                    if(lvl == 1){
                        enemy.material = new Material("resources/EnemyL1.png");
                    }
                    else if(lvl == 2){
                        enemy.material = new Material("resources/EnemyL2.png");
                    }
                    else{
                        enemy.material = new Material("resources/EnemyL3.png");
                    }

                    GatorEngine.OBJECTLIST.add(enemy);
                    gm.AddToScene(enemy);
                    gm.AddToCurrentEnemyList(enemy);

                    currentX += 50;
                }
                currentX = startX;
                currentY += 55;
            }
            if(firstLoop){
                enemyLevelCap++;
            }
        }
        else if(currentLevel == 3){
            // 3 rows of 8, all levels
            for(int i = 0; i < 3; i++){
                for(int j = 0; j < 8; j++){
                    GameObject enemy = new GameObject(currentX,currentY);
                    enemy.shape = new Ellipse2D.Float(0, 0, 50, 50);
                    int lvl = GenerateEnemyLevelValue();
                    enemy.scripts.add(new EnemyController(enemy, gm, lvl));
                    if(lvl == 1){
                        enemy.material = new Material("resources/EnemyL1.png");
                    }
                    else if(lvl == 2){
                        enemy.material = new Material("resources/EnemyL2.png");
                    }
                    else{
                        enemy.material = new Material("resources/EnemyL3.png");
                    }
                    //enemy.material = new Material("resources/EnemyL1.png");

                    GatorEngine.OBJECTLIST.add(enemy);
                    gm.AddToScene(enemy);
                    gm.AddToCurrentEnemyList(enemy);

                    currentX += 50;
                }
                currentX = startX;
                currentY += 55;
            }
            if(firstLoop){
                firstLoop = false;
            }
        }

        waveWaitTimer = waveWaitTime;
        currentLevel++;
        gm.playerLives = 3;
        gm.resetPlayerLives = true;
        gm.IncrementWavesCleared();
        if(currentLevel > 3){
            currentLevel = 1;
        }
    }

    private int GenerateEnemyLevelValue(){
        double d = Math.random();
        int lvl;
        if(d < .33){
            lvl = 1;
        }
        else if(d > .66){
            lvl = 3;
        }
        else{
            lvl = 2;
        }

        if(lvl > enemyLevelCap){
            lvl = enemyLevelCap;
        }

        return lvl;
    }
}
