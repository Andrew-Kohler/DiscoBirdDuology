import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class Material {
    Color fill, border;
    int borderWidth;
    boolean isShape = true;
    BufferedImage img;

    //Creates default, black fill and border with zero borderWidth
    Material(){
        fill = new Color(0,0,0);
        border = new Color(0,0,0);
        borderWidth = 0;
    }

    //Sets the fields
    public Material(Color fill, Color border, int borderWidth) {
        this.fill = fill;
        this.border = border;
        this.borderWidth = borderWidth;
    }

    //Loads the image at the path and sets isShape flag to false
    public Material(String path){
        isShape = false;
        setImg(path);
    }

    //Getters and Setters, done for you!
    public Color getFill() {
        return fill;
    }

    public void setFill(Color fill) {
        this.fill = fill;
    }

    public Color getBorder() {
        return border;
    }

    public void setBorder(Color border) {
        this.border = border;
    }

    public int getBorderWidth() {
        return borderWidth;
    }

    public void setBorderWidth(int stroke_width) {
        this.borderWidth = stroke_width;
    }

    public BufferedImage getImg(){return img;}

    //Load the image and set it
    public void setImg(String path){
        try{
            img = ImageIO.read(new File(path));
        }
        catch(IOException e){
        }

    }

    public void setImg(BufferedImage img){this.img=img;}


}
