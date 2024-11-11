public class ProjectileScript extends ScriptableBehavior{

    boolean isPlayer;   // Whether this is a player or enemy projectile
    float projectileSpeed; // What speed the projectile goes at
    GameManagerScript gm;

    ProjectileScript(GameObject g, GameManagerScript gm, boolean player, float speed) {
        super(g);
        isPlayer = player;
        projectileSpeed = speed;
        this.gm = gm;
    }

    @Override
    public void Start() {

    }

    @Override
    public void Update() {

        // Movement
        if(isPlayer){
            gameObject.Translate(0,-projectileSpeed);
        }
        else{
            gameObject.Translate(0,projectileSpeed);
        }

        // Destruction (miss)
        if(gameObject.transform.getTranslateY() < -10 || gameObject.transform.getTranslateY() > 510){
            GatorEngine.Delete(gameObject);
        }
    }
}
