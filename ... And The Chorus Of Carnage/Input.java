import java.util.ArrayList;

public class Input {
    static public ArrayList<Character> pressed = new ArrayList<>(); //contains characters that were just pressed this frame
    static public ArrayList<Character> held = new ArrayList<>(); //contains characters that were either just pressed this frame, or have been down for any number of previous frames
    static public ArrayList<Character> released = new ArrayList<>(); //contains characters that were just released this frame

    public static int MouseX; //the current mouse X position on the DISPLAY BufferedImage
    public static int MouseY; //the current mouse Y position on the DISPLAY BufferedImage
    public static boolean MousePressed; //true if the mouse is currently down
    public static boolean MouseClicked; //true if the mouse was clicked this frame

    //TODO: this function should happen every frame, and should clear any values in the Input class that need to be removed
    //i.e., if a key was pressed on one frame, on the next it should be removed from the pressed list
    static void UpdateInputs(){
        pressed.clear();    // So, all our inputs in pressed are removed

        for (int i = 0; i < held.size(); i++){ // But for held, we only remove them if they're in released
            //System.out.print(held.get(i) + " ");
            if(GetKeyUp(held.get(i))){
                held.remove(i);
            }
        }
        // And then we clear out released
        released.clear();
        MouseClicked = false;
        //System.out.println(MouseX + " " + MouseY);

        // So if something happened where released gets cleared, but there's still a key in "held", that key will remain held until the key is pressed again


    }

    //Returns true if c is in the released list
    static boolean GetKeyPressed(char c){
        return pressed.contains(c);
    }

    //Returns true if c is in the held list
    static boolean GetKeyDown(char c){
        return held.contains(c);
    }

    //Returns true if c is in the released list
    static boolean GetKeyUp(char c){
        return released.contains(c);
    }
}
