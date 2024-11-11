import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.lang.reflect.Array;
import java.util.ArrayList;

public class GameObject {
    public AffineTransform transform;   //the location/scale/rotation of our object
    public Shape shape;                 //the collider/rendered shape of this object
    public Material material;           //data about the fill color, border color, and border thickness
    public ArrayList<ScriptableBehavior> scripts = new ArrayList<>(); //all scripts attached to the object
    public boolean active = true;       //whether this gets Updated() and Draw()n

    private float x = 0;    // Keeps track of object position/translation for when we are scaling
    private float y = 0;

    //Creates the default GameObject use a default AffineTransform, default Material, and a 10x10 pix rectangle Shape at 0,0
    public GameObject(){
        transform = new AffineTransform();
        material = new Material();
        shape = new Rectangle2D.Float(0, 0, 10, 10);

    }

    //Creates the default GameObject, but with its AffineTransform translated to the coordinate x,y
    public GameObject(int x, int y){
        transform = new AffineTransform();
        material = new Material();
        shape = new Rectangle2D.Float(0, 0, 10, 10);

        transform.translate(x, y);
        this.x += x;
        this.y += y;
    }

    //Saves the pen's old transform, transforms it based on this object's transform, and draws either the styled shape, or the image scaled to the bounds of the shape.
    public void Draw(Graphics2D pen){
        if(active){ // Only draw if active
            AffineTransform oldPen = pen.getTransform();
            pen.transform((transform));
            if(material.isShape){
                pen.setColor(material.getFill());
                pen.fill(shape);

                pen.setStroke(new BasicStroke(material.getBorderWidth()));
                pen.setColor(material.getBorder());
                pen.draw(shape);
                //pen.draw(shape.getBounds2D());
                //System.out.println(transform.getTranslateX() + " " + transform.getTranslateY());

            }
            else{
                // Scale the pen to the correct size based on the image and shape dimensions
                double xScale = shape.getBounds2D().getWidth() / material.getImg().getWidth();
                double yScale = shape.getBounds2D().getHeight() / material.getImg().getHeight();
                //System.out.println(xScale + " " + yScale);
                pen.scale(xScale, yScale);

                pen.drawImage(material.getImg(), 0,0, null);
            }
            //shape.getBounds2D().setRect(x, y, shape.getBounds2D().getWidth(), shape.getBounds2D().getHeight());
            //shape.getBounds2D().setFrame(x, y, shape.getBounds2D().getWidth(), shape.getBounds2D().getHeight());
            pen.setTransform(oldPen);
        }

    }

    //Starts all scripts on the object
    public void Start(){
        if(active){
            for(int i = 0; i < scripts.size(); i++){
                scripts.get(i).Start();
            }
        }
    }

    //Updates all scripts on the object
    public void Update(){
        if(active){
            for(int i = 0; i < scripts.size(); i++){
                scripts.get(i).Update();
            }
        }
    }

    // Moves the GameObject's transform
    public void Translate(float dX, float dY){
        transform.translate(dX,dY);
        x += dX;
        y += dY;
    }

    //Scales the GameObject's transform around the CENTER of its shape
    public void Scale(float sX, float sY){
        transform.translate(x/2, y/2);
        transform.scale(sX, sY);
        transform.translate(-x/2, -y/2);
    }

    //Returns true if the two objects are touching (i.e., the intersection of their areas is not empty)
    public boolean CollidesWith(GameObject other){
        double x = transform.getTranslateX();
        double y = transform.getTranslateY();
        double w = shape.getBounds2D().getWidth();
        double h = shape.getBounds2D().getHeight();

        double otherX = other.transform.getTranslateX();
        double otherY = other.transform.getTranslateY();
        double otherW = other.shape.getBounds2D().getWidth();
        double otherH = other.shape.getBounds2D().getHeight();

        Shape rect = new Rectangle2D.Float((float)x, (float)y, (float)w, (float)h);

        Shape otherRect = new Rectangle2D.Float((float)otherX, (float)otherY, (float)otherW, (float)otherH);

        return rect.getBounds2D().intersects(otherRect.getBounds2D());
    }

    //Returns true if the shape on screen contains the point
    public boolean Contains(Point2D point){
        double x = transform.getTranslateX();
        double y = transform.getTranslateY();
        double w = shape.getBounds2D().getWidth();
        double h = shape.getBounds2D().getHeight();

        Shape rect = new Rectangle2D.Float((float)x, (float)y, (float)w, (float)h);

        return rect.contains(point);

    }

}
