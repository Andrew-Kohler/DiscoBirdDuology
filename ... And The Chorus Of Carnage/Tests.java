// To use, put
// TestControllerUpdate() in your Update() function if you have input done.
// or
// Call one of the test functions in Start()

import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;

public class Tests {

    static void TestControllerUpdate(){
        if(Input.GetKeyDown('1')){
            ResetEngine();
            TestOne();
        }

        if(Input.GetKeyDown('2')){
            ResetEngine();
            TestTwo();
        }

        if(Input.GetKeyDown('3')){
            ResetEngine();
            TestThree();
        }

        if(Input.GetKeyDown('4')){
            ResetEngine();
            TestFour();
        }

        if(Input.GetKeyDown('5')){
            ResetEngine();
            TestFive();
        }

        if(Input.GetKeyDown('6')){
            ResetEngine();
            TestSix();
        }

        if(Input.GetKeyDown('7')){
            ResetEngine();
            TestSeven();
        }

        if(Input.GetKeyDown('8')){
            ResetEngine();
            TestEight();
        }

        if(Input.GetKeyDown('9')){
            ResetEngine();
            TestNine();
        }
    }

    static void ResetEngine(){
        GatorEngine.OBJECTLIST.clear();
    }


    //Test: Default GameObject Constructor. Position GameObject Constructor.
    static void TestOne(){
        //Example: creating a default GameObject
        GameObject g = new GameObject();
        GatorEngine.OBJECTLIST.add(g);

        //Example: creating a default GameObject
        GameObject g2 = new GameObject(50,50);
        GatorEngine.OBJECTLIST.add(g2);
    }

    //Test: Materials
    static void TestTwo(){
        //Example: creating a GameObject at a custom location, then overriding the default shape/material
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.ORANGE,Color.BLUE,3);
        GatorEngine.OBJECTLIST.add(g);

        //Example: creating a GameObject at a location, setting a shape and image material
        GameObject g2 = new GameObject(150,150);
        g2.shape = new Rectangle2D.Float(0, 0, 100, 100);
        g2.material = new Material("resources/gator.jpg");
        GatorEngine.OBJECTLIST.add(g2);

        //Example: creating a GameObject at a location, setting a shape and image material. Same image as g2, but different size
        GameObject g3 = new GameObject(250,250);
        g3.shape = new Rectangle2D.Float(0, 0, 200, 200);
        g3.material = new Material("resources/gator.jpg");
        GatorEngine.OBJECTLIST.add(g3);
    }

    //Test: movement script
    static void TestThree(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.ORANGE,Color.BLUE,3);
        g.scripts.add(new Mover(g));
        GatorEngine.OBJECTLIST.add(g);
    }

    //Test: scale script
    static void TestFour(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.ORANGE,Color.BLUE,3);
        g.scripts.add(new Scaler(g));
        GatorEngine.OBJECTLIST.add(g);
    }

    //Tests: key input
    static void TestFive(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.ORANGE,Color.BLUE,3);
        g.scripts.add(new Mover2(g));
        GatorEngine.OBJECTLIST.add(g);
    }

    //Tests: mouse inputs
    static void TestSix(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.GREEN,Color.BLACK,3);
        g.scripts.add(new MouseFollow(g));
        GatorEngine.OBJECTLIST.add(g);
    }

    //Tests: mouse inputs + scripts with references to other objects
    static void TestSeven(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.GREEN,Color.BLACK,3);
        g.scripts.add(new MouseFollow(g));
        GatorEngine.OBJECTLIST.add(g);

        GameObject g2 = new GameObject(50,50);
        g2.scripts.add(new ObjectFollow(g2,g));
        GatorEngine.OBJECTLIST.add(g2);
    }

    //Tests: collision
    static void TestEight(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.GREEN,Color.BLACK,3);
        g.scripts.add(new MouseFollow(g));
        GatorEngine.OBJECTLIST.add(g);

        GameObject g2 = new GameObject(250,250);
        g2.shape = new Ellipse2D.Float(0,0,150,150);
        g2.scripts.add(new CollisionCheck(g2,g));
        GatorEngine.OBJECTLIST.add(g2);

    }

    static void TestNine(){
        GameObject g = new GameObject(50,50);
        g.shape = new Ellipse2D.Float(0,0,50,50);
        g.material = new Material(Color.GREEN,Color.BLACK,3);
        g.scripts.add(new MouseFollow(g));
        g.scripts.add(new Spawner(g));
        GatorEngine.OBJECTLIST.add(g);


    }


    static public class Spawner  extends ScriptableBehavior {
        ArrayList<GameObject> spawned = new ArrayList<>();

        Spawner(GameObject g) {
            super(g);
        }

        @Override
        public void Start() {

        }

        @Override
        public void Update(){
            GameObject g = new GameObject((int)gameObject.transform.getTranslateX(), (int)gameObject.transform.getTranslateY());
            GatorEngine.Create(g);
            spawned.add(g);

            if(spawned.size()>100){
                GameObject old = spawned.get(0);
                GatorEngine.Delete(old);
                spawned.remove(0);
            }
        }
    }


    static public class Mover  extends ScriptableBehavior {
        Mover(GameObject g) {
            super(g);
        }

        @Override
        public void Start() {

        }

        @Override
        public void Update(){
            gameObject.Translate(1,0);
        }
    }

    static public class Mover2  extends ScriptableBehavior {
        Mover2(GameObject g) {
            super(g);
        }

        @Override
        public void Start() {

        }

        @Override
        public void Update(){
            if(Input.GetKeyDown('a'))
                gameObject.Translate(-1,0);
            if(Input.GetKeyDown('d'))
                gameObject.Translate(1,0);
            if(Input.GetKeyDown('w'))
                gameObject.Translate(0, -1);
            if(Input.GetKeyDown('s'))
                gameObject.Translate(0,1);
        }


    }

    static public class Scaler extends ScriptableBehavior {
        Scaler(GameObject g) {
            super(g);
        }

        @Override
        public void Start() {

        }

        @Override
        public void Update(){

            gameObject.Scale(1.01f,1.01f);

        }
    }

    static public class MouseFollow extends ScriptableBehavior{
        Color not_clicked;
        Color clicked;

        MouseFollow(GameObject g) {
            super(g);
            not_clicked = Color.RED;
            clicked = Color.GREEN;
        }

        @Override
        public void Start() {
        }

        @Override
        public void Update() {
            if(!Input.MousePressed) {
                gameObject.transform.setToTranslation(Input.MouseX-gameObject.shape.getBounds().getWidth()/2, Input.MouseY-gameObject.shape.getBounds().getHeight()/2);
                gameObject.material.setFill(not_clicked);
            }else
                gameObject.material.setFill(clicked);
        }
    }

    static public class ObjectFollow extends ScriptableBehavior{
        GameObject follow_this;

        ObjectFollow(GameObject g, GameObject other) {
            super(g);
            this.follow_this = other;
        }

        @Override
        public void Start() {
        }

        @Override
        public void Update() {
            double x = follow_this.transform.getTranslateX()-gameObject.transform.getTranslateX();
            double y = follow_this.transform.getTranslateY()-gameObject.transform.getTranslateY();

            x/=50;
            y/=50;
            gameObject.Translate((float)x,(float)y);
        }
    }

    static public class CollisionCheck extends ScriptableBehavior{
        Color not_colliding;
        Color colliding;
        GameObject other;

        CollisionCheck(GameObject g, GameObject other) {
            super(g);
            this.other = other;
            not_colliding = Color.BLUE;
            colliding = Color.ORANGE;
        }

        @Override
        public void Start() {
        }

        @Override
        public void Update() {
            if(gameObject.CollidesWith(other)) {
                gameObject.material.setFill(not_colliding);
            }else
                gameObject.material.setFill(colliding);
        }
    }
}
