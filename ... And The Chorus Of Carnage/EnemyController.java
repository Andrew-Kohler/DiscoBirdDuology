import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.util.Random;

public class EnemyController extends ScriptableBehavior{
    int level; // Power level of the vulture
    float fireChance; // The chance an enemy has to shoot when it changes direction (0-1)
    float enemySpeed = .5f; // How fast enemies move

    int moveDist = 50;  // How far enemies move each time they change direction
    float distanceMoved;
    int cycleCount; // A simple int counter that determines which direction we're going

    GameManagerScript gm;

    EnemyController(GameObject g, GameManagerScript gm, int level) {
        super(g);
        this.gm = gm;
        this.level = level;
    }

    @Override
    public void Start() {
        if(level == 1){
            gameObject.material.setImg("resources/EnemyL1.png");
            fireChance = .3f;
        }
        if(level == 2){
            gameObject.material.setImg("resources/EnemyL2.png");
            fireChance = .6f;
        }
        else{
            gameObject.material.setImg("resources/EnemyL3.png");
            fireChance = .8f;
        }
    }

    //TODO
    // Projectile deals damage
    // Taking damage from player projectiles

    @Override
    public void Update() {
        // Movement
        if(cycleCount > 3){
            cycleCount = 0;
        }

        if(cycleCount == 0){    // Moving right
            gameObject.Translate(enemySpeed,0);
        }
        else if(cycleCount == 1 || cycleCount == 3){    // Moving down
            gameObject.Translate(0,enemySpeed);
        }
        else if(cycleCount == 2){ // Moving left
            gameObject.Translate(-enemySpeed,0);
        }

        distanceMoved += enemySpeed;    // Direction changer
        if(distanceMoved >= moveDist){
            distanceMoved = 0;
            cycleCount++;

            if(fireChance > Math.random()){ // Roll to attack
                // Fire a projectile
                GameObject proj = new GameObject((int)gameObject.transform.getTranslateX() + 25,(int)gameObject.transform.getTranslateY() + 45);
                proj.shape = new Ellipse2D.Float(0, 0, 16, 18);
                proj.material = new Material("resources/EnemyProj.png");
                proj.scripts.add(new ProjectileScript(proj, gm, false, 5f));
                GatorEngine.OBJECTLIST.add(proj);
                gm.AddToScene(proj);
                gm.AddToEnemyProjList(proj);
            }
        }

        // Taking damage
        for(int i = 0; i < gm.GetPlayerProjList().size(); i++){
            if(gm.GetPlayerProjList().get(i).CollidesWith(gameObject)){ // Do a check for if we are hit
                GatorEngine.Delete(gm.GetPlayerProjList().get(i));
                gm.RemoveFromPlayerProjList(gm.GetPlayerProjList().get(i)); // Delete that projectile
                DamageEnemy();
                break;
            }
        }


        // Check for an enemy victory based on position
        if(gameObject.transform.getTranslateY() >= 390){
            if(gm.GetWavesCleared() >= 3){
                gm.SetScene(3);
            }
            else{
                gm.SetScene(2);
            }
        }

        // Animation and levelling down
        if(level == 1){
            //gameObject.material.setImg("resources/EnemyL1.png");
            fireChance = .3f;
        }
        else if(level == 2){
            //gameObject.material.setImg("resources/EnemyL2.png");
            fireChance = .6f;
        }
        else if(level == 3){
            //gameObject.material.setImg("resources/EnemyL3.png");
            fireChance = .8f;
        }


    }

    public void DamageEnemy(){
        level--;
        if(level == 1){
            gameObject.material.setImg("resources/EnemyL1.png");
            fireChance = .3f;
        }
        else if(level == 2){
            gameObject.material.setImg("resources/EnemyL2.png");
            fireChance = .6f;
        }
        else if(level == 3){
            gameObject.material.setImg("resources/EnemyL3.png");
            fireChance = .8f;
        }
        else if(level == 0){
            gm.RemoveFromCurrentEnemyList(gameObject);
            GatorEngine.Delete(gameObject);
        }
    }
}
