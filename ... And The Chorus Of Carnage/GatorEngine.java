import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

public class GatorEngine {
    //UI Components (things that are "more" related to the UI)
    static JFrame WINDOW;
    static JPanel DISPLAY_CONTAINER;
    static JLabel DISPLAY_LABEL;
    static BufferedImage DISPLAY;
    static BufferedImage BG;
    static int WIDTH=500, HEIGHT=500;

    //Engine Components (things that are "more" related to the engine structures)
    static Graphics2D RENDERER;
    static ArrayList<GameObject> OBJECTLIST = new ArrayList<>(); //list of GameObjects in the scene
    static ArrayList<GameObject> CREATELIST = new ArrayList<>(); //list of GameObjects to add to OBJECTLIST at the end of the frame
    static ArrayList<GameObject> DELETELIST = new ArrayList<>(); //list of GameObjects to remove from OBJECTLIST at the end fo the frame
    static float FRAMERATE = 60;                //target frames per second;
    static float FRAMEDELAY = 1000/FRAMERATE;   //target delay between frames
    static Timer FRAMETIMER;                    //Timer controlling the update loop
    static Thread FRAMETHREAD;                  //the Thread implementing the update loop
    static Thread ACTIVE_FRAMETHREAD;           //a copy of FRAMETHREAD that actually runs.


    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                CreateEngineWindow();
            }
        });
    }

    static void CreateEngineWindow(){
        //Sets up the GUI
        WINDOW = new JFrame("Disco Bird and the Chorus of Carnage");
        WINDOW.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        WINDOW.setVisible(true);

        DISPLAY = new BufferedImage(WIDTH,HEIGHT,BufferedImage.TYPE_INT_ARGB);
        RENDERER = (Graphics2D) DISPLAY.getGraphics();
        DISPLAY_CONTAINER = new JPanel();
        DISPLAY_CONTAINER.setFocusable(true);
        DISPLAY_LABEL = new JLabel(new ImageIcon(DISPLAY));
        DISPLAY_CONTAINER.add(DISPLAY_LABEL);
        WINDOW.add(DISPLAY_CONTAINER);
        WINDOW.pack();

        // Executes Update(), clears any inputs that need to be removed between frames, and repaints the GUI back on the EDT.
        FRAMETHREAD = new Thread(new Runnable() {
            @Override
            public void run() {

                Update();
                Input.UpdateInputs();
                UpdateObjectList();

                SwingUtilities.invokeLater(new Runnable() {
                    @Override
                    public void run() {
                        WINDOW.repaint();
                    }
                });
            }
        });

        //This copies the template thread made above
        ACTIVE_FRAMETHREAD = new Thread(FRAMETHREAD);

        //Create a timer that will create/run ACTIVE_FRAMETHREAD, but only if it hasn't started/has ended
        FRAMETIMER = new Timer((int)FRAMEDELAY, new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if(!ACTIVE_FRAMETHREAD.isAlive()){
                    ACTIVE_FRAMETHREAD = new Thread(FRAMETHREAD);
                    ACTIVE_FRAMETHREAD.start();
                }
                FRAMETIMER.restart();
            }
        });
        FRAMETIMER.start();

        Start();

        //===================INPUT=========================
        //Set up some action listeners for input on the PANEL
        //These should update the Input classes ArrayLists and other members
        //TODO: use the correct listener functions to modify INPUT
        DISPLAY_CONTAINER.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent e) {

            }

            @Override
            public void keyPressed(KeyEvent e) {
                Input.pressed.add(e.getKeyChar()); // If a key is pressed, we add it to pressed
                if(!Input.GetKeyDown(e.getKeyChar())){  // We only add a key to held if it isn't already held
                    Input.held.add(e.getKeyChar());
                }


            }

            @Override
            public void keyReleased(KeyEvent e) {
                Input.released.add(e.getKeyChar());
                if(Input.held.indexOf(e.getKeyChar()) >= 0){
                    Input.held.remove(Input.held.indexOf(e.getKeyChar()));
                }
            }
        });
        DISPLAY_CONTAINER.addMouseListener(new MouseListener() {
            @Override
            public void mouseClicked(MouseEvent e) {
                /*if (Input.MouseClicked = false) {
                    Input.MouseClicked = true;
                }
                else{
                    Input.MouseClicked = false;
                }*/
                Input.MouseClicked = true;
            }

            @Override
            public void mousePressed(MouseEvent e) {
                Input.MousePressed = true;
            }

            @Override
            public void mouseReleased(MouseEvent e) {
                Input.MouseClicked = false;
                Input.MousePressed = false;
            }

            @Override
            public void mouseEntered(MouseEvent e) {

            }

            @Override
            public void mouseExited(MouseEvent e) {

            }
        });
        DISPLAY_CONTAINER.addMouseMotionListener(new MouseMotionListener() {
            @Override
            public void mouseDragged(MouseEvent e) {
                Input.MouseX = e.getX();
                Input.MouseY = e.getY();
            }

            @Override
            public void mouseMoved(MouseEvent e) {
                Input.MouseX = e.getX();
                Input.MouseY = e.getY();
            }
        });
    }

    // Adds the GameObject to the CREATELIST
    static void Create(GameObject g){
        CREATELIST.add(g);
    }

    // Adds the GameObject to the DELETELIST
    static void Delete(GameObject g){
        DELETELIST.add(g);
    }

    //Removes objects in DELETELIST from OBJECTLIST, adds objects in CREATELIST to OBJECTLIST, and removes all items from DELETELIST and CREATELIST
    static void UpdateObjectList(){
        for(GameObject g:CREATELIST){
            OBJECTLIST.add(g);
        }
        for(GameObject o:DELETELIST){
            OBJECTLIST.remove(o);
        }
        CREATELIST.clear();
        DELETELIST.clear();

    }



    //This begins the "user-side" of the software; above should set up the engine loop, data, etc.
    //Here you can create GameObjects, assign scripts, set parameters, etc.
    //NOTE: This is where we should be able to insert out own code and scripts
    static void Start(){
        // Start of client writable area -------------------
        GameObject gameManager = new GameObject();
        gameManager.shape = new Ellipse2D.Float(0,0,50,50);
        gameManager.material = new Material(new Color(0, true),new Color(0, true),1);
        gameManager.scripts.add(new GameManagerScript(gameManager));
        GatorEngine.OBJECTLIST.add(gameManager);



        //Tests.TestNine();//create some example objects, see the function in Tests.java



        // End of writable area -------------------
        for(GameObject g:OBJECTLIST){ // Start() all objects in OBJECTLIST
            g.Start();
        }

    }

    //Redraws the Background(), then Draw()s and Update()s all GameObjects in OBJECTLIST
    static void Update(){
        Background();
        for(int i = 0; i < OBJECTLIST.size(); i++){
            OBJECTLIST.get(i).Draw(RENDERER);
            OBJECTLIST.get(i).Update();
        }
    }

    //draws a background on the Renderer. right now it is solid, but we could load an image
    //done for you!
    static void Background(){
        if(BG != null){
            RENDERER.drawImage(BG, 0, 0, WIDTH, HEIGHT, null);
        }
        else{
            RENDERER.setColor(Color.WHITE);
            RENDERER.fillRect(0,0,WIDTH,HEIGHT);
        }

    }

    public static void SetBackground(String path){
        try{
            BG = ImageIO.read(new File(path));
        }
        catch(IOException e){
            System.out.println("Uh oh gamer!");
        }
    }

}

