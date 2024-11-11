import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;

public class Scenes {
    //The giga TODO
    // Indicator for dash recharge/usage

    static void SceneZero(GameManagerScript gameManager){    // Start screen
        // We need a background and a button
        gameManager.ClearScene();
        gameManager.ResetGame();
        GatorEngine.SetBackground("resources/Title.png");

        GameObject g = new GameObject(175,365);
        g.shape = new Ellipse2D.Float(0, 0, 155, 65);
        g.material = new Material(new Color(0, true),new Color(0, true),3);
        g.scripts.add(new SceneChangeButtonScript(g, gameManager, 1));
        GatorEngine.OBJECTLIST.add(g);
        gameManager.AddToScene(g);
    }

    static void SceneOne(GameManagerScript gameManager){     // Gameplay
        gameManager.ClearScene();
        GatorEngine.SetBackground("resources/GameplayBG.png");

        // Create the player
        GameObject player = new GameObject(225,400);
        player.shape = new Ellipse2D.Float(0, 0, 50, 50);
        player.material = new Material("resources/DB-Normal.png");
        player.scripts.add(new PlayerController(player, gameManager));
        GatorEngine.OBJECTLIST.add(player);
        gameManager.AddToScene(player);

        player.Start();

        // Create the Health UI
        GameObject ui = new GameObject(0,0);
        ui.shape = new Ellipse2D.Float(0, 0, 5, 5);
        ui.material = new Material(new Color(0, true),new Color(0, true),3);
        ui.scripts.add(new HealthUIScript(ui, gameManager));
        GatorEngine.OBJECTLIST.add(ui);
        gameManager.AddToScene(ui);

        // Create a "Level Manager" that handles the spawning of enemies
        GameObject levelManager = new GameObject(0,0);
        levelManager.shape = new Ellipse2D.Float(0, 0, 5, 5);
        levelManager.material = new Material(new Color(0, true),new Color(0, true),3);
        levelManager.scripts.add(new LevelManagerScript(levelManager, gameManager));
        GatorEngine.OBJECTLIST.add(levelManager);
        gameManager.AddToScene(levelManager);
    }

    static void SceneTwo(GameManagerScript gameManager){     // Bad ending - for if the player clears less than 3 waves
        gameManager.ClearScene();
        GatorEngine.SetBackground("resources/BadEnd.png");

        GameObject g = new GameObject(15,415);
        g.shape = new Ellipse2D.Float(0, 0, 255, 65);
        g.material = new Material(new Color(0, true),new Color(0, true),3);
        g.scripts.add(new SceneChangeButtonScript(g, gameManager, 0));
        GatorEngine.OBJECTLIST.add(g);
        gameManager.AddToScene(g);
    }

    static void SceneThree(GameManagerScript gameManager){   // Good ending - for if the player clears 3 or more waves
        gameManager.ClearScene();
        GatorEngine.SetBackground("resources/GoodEnd.png");

        GameObject g = new GameObject(15,415);
        g.shape = new Ellipse2D.Float(0, 0, 255, 65);
        g.material = new Material(new Color(0, true),new Color(0, true),3);
        g.scripts.add(new SceneChangeButtonScript(g, gameManager, 0));
        GatorEngine.OBJECTLIST.add(g);
        gameManager.AddToScene(g);

    }
}
