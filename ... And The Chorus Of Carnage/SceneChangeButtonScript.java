import java.awt.*;
import java.awt.geom.Point2D;

public class SceneChangeButtonScript extends ScriptableBehavior{
    int scene;
    GameManagerScript gm;

    SceneChangeButtonScript(GameObject g, GameManagerScript gameManager, int scene) {
        super(g);
        this.scene = scene;
        gm = gameManager;
    }

    @Override
    public void Start() {

    }

    @Override
    public void Update() {
        if(gameObject.Contains(new Point2D.Float(Input.MouseX, Input.MouseY))){
            gameObject.material.setFill(Color.WHITE); // Changes hover color
            if(Input.MouseClicked){ // If the mouse is clicked
                gm.SetScene(scene);
            }
        }
        else{
            gameObject.material.setFill(new Color(0, true));
        }
    }
}
