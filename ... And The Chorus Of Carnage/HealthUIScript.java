import java.awt.geom.Ellipse2D;
import java.util.ArrayList;
import java.util.Stack;

public class HealthUIScript extends ScriptableBehavior{

    GameManagerScript gm;

    Stack<GameObject> lives = new Stack<>();

    int currentLives = 3;
    int livesLastFrame = -1;

    HealthUIScript(GameObject g, GameManagerScript gm) {
        super(g);
        this.gm = gm;
    }

    @Override
    public void Start() {

    }

    @Override
    public void Update() {
        currentLives = gm.playerLives;
        if(gm.resetPlayerLives){
            gm.resetPlayerLives = false;
            ResetLifeView();
        }
        if(currentLives != livesLastFrame){
            UpdateLifeView();
        }



        livesLastFrame = currentLives;

    }

    private void UpdateLifeView(){
        if(currentLives == 3 && livesLastFrame == -1){  // Check for creating this display for the first time
            for(int i = 0; i < 3; i++){
                GameObject life = new GameObject(0 + i*41,455);
                life.shape = new Ellipse2D.Float(0, 0, 40, 40);
                life.material = new Material("resources/DB-Normal.png");
                GatorEngine.OBJECTLIST.add(life);
                gm.AddToScene(life);
                lives.push(life);
            }
        }
        else{ // Any access of this method for non-creation purposes is destructive
            if(lives.size() != 0){
                GatorEngine.Delete(lives.peek());
                lives.pop();
            }

        }
    }

    private void ResetLifeView(){
        while(lives.size() > 0){
            GatorEngine.Delete(lives.peek());
            lives.pop();
        }
        for(int i = 0; i < 3; i++){
            GameObject life = new GameObject(0 + i*41,455);
            life.shape = new Ellipse2D.Float(0, 0, 40, 40);
            life.material = new Material("resources/DB-Normal.png");
            GatorEngine.OBJECTLIST.add(life);
            gm.AddToScene(life);
            lives.push(life);
        }
        livesLastFrame = currentLives;
    }
}
