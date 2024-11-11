import java.util.ArrayList;
// Delta time implementation sourced from https://gamedev.stackexchange.com/questions/111741/calculating-delta-time

public class GameManagerScript extends  ScriptableBehavior{
    static ArrayList<GameObject> SCENELIST = new ArrayList<>(); // Array of objects in the loaded scene

    ArrayList<GameObject> playerProjList = new ArrayList<>(); // All player projectiles
    ArrayList<GameObject> enemyProjList = new ArrayList<>(); // All enemy projectiles

    ArrayList<GameObject> currentEnemyList = new ArrayList<>(); // All enemy projectiles

    int currentScene;       // These help us only load in a scene if we underwent a scene change
    int currentLastFrame;

    int wavesCleared;   // Important game data that multiple classes might be changing or referencing
    int playerLives;
    boolean resetPlayerLives = false;

    long last_time = System.nanoTime(); // For calculating delta time
    int delta_time;

    GameManagerScript(GameObject g) {
        super(g);
    }

    @Override
    public void Start() {
        currentScene = 0;
        currentLastFrame = -1;

        wavesCleared = 0;
        playerLives = 3;
    }

    @Override
    public void Update() {
        long time = System.nanoTime();
        delta_time = (int) ((time - last_time) / 1000000);
        last_time = time;

        if(currentScene != currentLastFrame){
            switch (currentScene){
                case 0:
                    Scenes.SceneZero(this);
                    break;
                case 1:
                    Scenes.SceneOne(this);
                    break;
                case 2:
                    Scenes.SceneTwo(this);
                    break;
                case 3:
                    Scenes.SceneThree(this);
                    break;
            }
        }

        currentLastFrame = currentScene;

        if(playerLives == 0){
            if(wavesCleared > 3){
                currentScene = 3;
            }
            else{
                currentScene = 2;
            }
        }

    }

    public void SetScene(int scene){
        currentScene = scene;
    }

    public int GetWavesCleared(){
        return wavesCleared;
    }

    public void IncrementWavesCleared(){
        wavesCleared++;
    }

    public void ResetGame(){
        wavesCleared = 0;
        playerLives = 3;
    }

    public void AddToScene(GameObject g){
        SCENELIST.add(g);
    }

    public void AddToPlayerProjList(GameObject g){
        playerProjList.add(g);
    }

    public void AddToEnemyProjList(GameObject g){
        enemyProjList.add(g);
    }

    public void AddToCurrentEnemyList(GameObject g){
        currentEnemyList.add(g);
    }

    public void RemoveFromPlayerProjList(GameObject g){
        playerProjList.remove(g);
    }

    public void RemoveFromEnemyProjList(GameObject g){
        enemyProjList.remove(g);
    }

    public void RemoveFromCurrentEnemyList(GameObject g){
        currentEnemyList.remove(g);
    }

    public ArrayList<GameObject> GetPlayerProjList(){
        return playerProjList;
    }

    public ArrayList<GameObject> GetEnemyProjList(){
        return enemyProjList;
    }

    public ArrayList<GameObject> GetCurrentEnemyList(){
        return currentEnemyList;
    }


    public void ClearScene(){   // Deletes everything in a scene so the next one is clear!
        for(int i = 0; i < SCENELIST.size(); i++){
            if(SCENELIST.get(i) != null)
                GatorEngine.Delete(SCENELIST.get(i));
        }
        playerProjList.clear();
        enemyProjList.clear();
        currentEnemyList.clear();
        SCENELIST.clear();
    }


}
