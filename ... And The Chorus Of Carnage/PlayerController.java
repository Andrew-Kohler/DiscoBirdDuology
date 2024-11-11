import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.util.ArrayList;

public class PlayerController extends ScriptableBehavior{

    float firingTimer;  // Timer for how often the player can fire a shot
    float iframeTimer;  // Timer for player i-frames / invulnerability period
    float redSwapTimer; // Animation timer for whether the sprite is red or not
    float dashRollTimer;// Timer for how long the dash roll lasts
    float dashCooldownTimer;

    float reloadTime = .5f; // Time that a recharge takes
    float iframeTime = 1f;  // Time that player is invincible for when hit
    float redSwapTime = .07f;   // Time it takes for player to flash red when in i frames
    float dashRollTime = .3f;
    float dashCooldownTime = 1f;

    float playerSpeed = 3f;

    boolean canGetHit;  // Whether the player is in i-frames or not
    boolean isRed;      // Whether the player sprite is in hurt mode or not

    boolean rolling;    // Whether we are using our special roll move
    boolean rollLeft = false;  // Direction of roll
    ArrayList<String> rollAnim = new ArrayList<String>();

    boolean bespokeAnimation; // If there is a bespoke animation in progress
    GameObject ind;
    boolean onlySetNullOnce;

    GameManagerScript gm;

    PlayerController(GameObject g, GameManagerScript gm) {
        super(g);
        this.gm = gm;
    }

    @Override
    public void Start() {
        firingTimer = 0;
        iframeTimer = 0;
        canGetHit = true;

        rollAnim.add("DB-Right");
        rollAnim.add("Roll1");
        rollAnim.add("Roll2");
        rollAnim.add("Roll3");
        rollAnim.add("Roll4");
        rollAnim.add("Roll5");
        rollAnim.add("DB-Left");
    }

    @Override
    public void Update() {
        // Movement
        if(!rolling){
            if(dashCooldownTimer > 0){ // Cooldown for the dash roll
                dashCooldownTimer -= (float)gm.delta_time/1000;
            }
            else if(dashCooldownTimer <= 0 && !onlySetNullOnce){
                ind = null;
                onlySetNullOnce = true;
            }

            if(Input.GetKeyDown('a') && gameObject.transform.getTranslateX() >= 0){
                gameObject.Translate(-playerSpeed,0);
                if(Input.GetKeyDown('p') && canGetHit && dashCooldownTimer <= 0){ // You can't roll during hurt i-frames, that's a rule now
                    rolling = true;
                    rollLeft = true;
                    canGetHit = false;
                    bespokeAnimation = true;
                    dashRollTimer = dashRollTime;
                }

            }

            if(Input.GetKeyDown('d') && gameObject.transform.getTranslateX() <= 450){
                gameObject.Translate(playerSpeed,0);
                if(Input.GetKeyDown('p') && canGetHit && dashCooldownTimer <= 0){
                    rolling = true;
                    rollLeft = false;
                    canGetHit = false;
                    bespokeAnimation = true;
                    dashRollTimer = dashRollTime;
                }
            }
        }
        else{
            DashRoll();
            dashRollTimer-= (float)gm.delta_time/1000;
                // We'll use this for the animation timer
        }


        // Attacking
        if(Input.GetKeyDown(' ') && firingTimer <= 0){
            firingTimer = reloadTime;

            // Create a new projectile
            GameObject proj = new GameObject((int)gameObject.transform.getTranslateX() + 25,(int)gameObject.transform.getTranslateY() + 5);
            proj.shape = new Ellipse2D.Float(0, 0, 10, 10);
            proj.material = new Material("resources/PlayerProj.png");
            proj.scripts.add(new ProjectileScript(proj, gm, true, 5f));
            GatorEngine.OBJECTLIST.add(proj);
            gm.AddToScene(proj);
            gm.AddToPlayerProjList(proj);
        }
        else if(firingTimer > 0){
            firingTimer -= (float)gm.delta_time/1000;
        }


        // Getting hurt
        if(canGetHit){
            for(int i = 0; i < gm.GetEnemyProjList().size(); i++){
                if(gm.GetEnemyProjList().get(i).CollidesWith(gameObject)){ // Do a check for if we are hit
                    GatorEngine.Delete(gm.GetEnemyProjList().get(i));
                    gm.RemoveFromEnemyProjList(gm.GetEnemyProjList().get(i)); // Delete that projectile

                    iframeTimer = iframeTime; // Start all the timers
                    redSwapTimer = redSwapTime;
                    canGetHit = false;
                    isRed = true;

                    gm.playerLives--;
                    break;
                }
            }
        }
        else{
            if(!rolling){
                if(iframeTimer > 0){
                    iframeTimer -= (float)gm.delta_time/1000;   // Ticking down the i-frame timer

                    redSwapTimer -= (float)gm.delta_time/1000;
                    if(redSwapTimer <= 0){  // Animation of the hurt flash
                        isRed = !isRed;
                        redSwapTimer = redSwapTime;
                    }
                }
                else{ // Reset back to normal, damageable conditions
                    canGetHit = true;
                    isRed = false;
                }
            }
        }

        // Animation
        if(!bespokeAnimation){
            if(Input.GetKeyDown('a')){  // Moving left
                if(isRed){
                    gameObject.material.setImg("resources/DB-HurtL.png");
                }
                else{
                    gameObject.material.setImg("resources/DB-Left.png");
                }
            }
            else if(Input.GetKeyDown('d')){ // Moving right
                if(isRed){
                    gameObject.material.setImg("resources/DB-HurtR.png");
                }
                else{
                    gameObject.material.setImg("resources/DB-Right.png");
                }
            }
            else{   // Dead ahead
                if(isRed){
                    gameObject.material.setImg("resources/DB-Hurt.png");
                }
                else{
                    gameObject.material.setImg("resources/DB-Normal.png");
                }
            }
        }

        // Literally just spawning and destroying the roll indicator
        DashInd();

    }

    public void DamagePlayer(){
        gm.playerLives--;
    }

    private void DashRoll(){
        // Movement
        if(rollLeft && gameObject.transform.getTranslateX() >= 0){
            gameObject.Translate(-playerSpeed * 2.5f,0);
        }
        else if(!rollLeft && gameObject.transform.getTranslateX() <= 450){
            gameObject.Translate(playerSpeed * 2.5f,0);
        }

        // Animation
        String currentFrame = "";
        if(!rollLeft){
            if(dashRollTimer < .043){
                currentFrame = rollAnim.get(6);
            }
            else if(dashRollTimer < .086){
                currentFrame = rollAnim.get(5);
            }
            else if(dashRollTimer < .129){
                currentFrame = rollAnim.get(4);
            }
            else if(dashRollTimer < .172){
                currentFrame = rollAnim.get(3);
            }
            else if(dashRollTimer < .215){
                currentFrame = rollAnim.get(2);
            }
            else if(dashRollTimer < .258){
                currentFrame = rollAnim.get(1);
            }
            else{
                currentFrame = rollAnim.get(0);
            }
        }
        else{
            if(dashRollTimer < .043){
                currentFrame = rollAnim.get(0);
            }
            else if(dashRollTimer < .086){
                currentFrame = rollAnim.get(1);
            }
            else if(dashRollTimer < .129){
                currentFrame = rollAnim.get(2);
            }
            else if(dashRollTimer < .172){
                currentFrame = rollAnim.get(3);
            }
            else if(dashRollTimer < .215){
                currentFrame = rollAnim.get(4);
            }
            else if(dashRollTimer < .258){
                currentFrame = rollAnim.get(5);
            }
            else{
                currentFrame = rollAnim.get(6);
            }
        }

        gameObject.material.setImg("resources/" + currentFrame + ".png");
        //Listen, I know it's horrendous, but it's the only animation in the game. I think I get this one.

        // Ending the dash roll
        if(dashRollTimer <= 0){
            rolling = false;
            canGetHit = true;
            bespokeAnimation = false;
            dashCooldownTimer = dashCooldownTime;

        }
    }

    private void DashInd(){
        if(dashRollTimer <= 0 && !rolling && ind == null){
            ind = new GameObject(450,450);
            ind.shape = new Rectangle2D.Float(0, 0, 40, 40);
            ind.material = new Material("resources/RollKey.png");
            GatorEngine.OBJECTLIST.add(ind);
            gm.AddToScene(ind);
        }

        if(dashRollTimer > 0 || rolling){
            GatorEngine.Delete(ind);
            onlySetNullOnce = false;

        }
    }
}
