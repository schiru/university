package HL3.AllThoseTerritories.model;

import java.awt.*;
import java.util.List;

/**
 * Created by lukas on 06/01/16.
 */
public class Patch {
    private List<Point> boundary;
    private Polygon shape;
    private Color color = Color.gray;
    private boolean hovered = false;
    private boolean selected = false;

    public Patch(List<Point> boundary){
        this.boundary = boundary;
        this.shape = createShape();
    }

    public boolean containsPoint(Point point) {
        if (shape == null) return false;

        return shape.contains(point.getX(), point.getY());
    }

    public void setColor(Color c) {
        color = c;
    }

    private Polygon createShape() {
        Polygon shape = new Polygon();

        // Only create shape if there are more than two points, otherwise it would
        // just be a line or a point.
        if (boundary.size() > 2)
            for (Point point : boundary) {
                shape.addPoint((int) point.getX(), (int) point.getY());
            }

        return shape;
    }

    public void drawInContext(Graphics2D g2d) {
        Graphics2D g2dSafe = (Graphics2D) g2d.create();

        // Fill the shape
        g2dSafe.setPaint(color);
        g2dSafe.fill(shape);

        // Draw the stroke on top
        if (hovered) {
            g2dSafe.setColor(Color.ORANGE);
        }else if (selected){
            g2dSafe.setColor(Color.GREEN);
        }
        else{
            g2dSafe.setColor(Color.darkGray);
        }
        g2dSafe.setStroke(new BasicStroke(2, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND));
        g2dSafe.draw(shape);

        // Dispose safe g2d element and all all temp settings (color, stroke, etc.)
        g2dSafe.dispose();

    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }

    public void setHovered(boolean hovered){
        this.hovered = hovered;
    }
}
