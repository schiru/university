package HL3.AllThoseTerritories;

import HL3.AllThoseTerritories.model.Territory;

import javax.swing.*;
import java.awt.*;
import java.util.List;
import java.util.Map;


/**
 * Created by thomas on 07/01/16.
 */
public class MapView extends JPanel {
    private Map<String, Territory> territories;

    public MapView(Map<String, Territory> territories) {
        this.territories = territories;
        setPreferredSize(new Dimension(1250, 650));
        setBackground(Color.WHITE);
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);

        Graphics2D g2d = (Graphics2D) g;

        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                RenderingHints.VALUE_ANTIALIAS_ON);

        g2d.setRenderingHint(RenderingHints.KEY_RENDERING,
                RenderingHints.VALUE_RENDER_QUALITY);


        // Draw connection between neighboring territories
        // TODO: Remove duplicates (Currently, a line from a to b AND b to a is drawn)
        for (Map.Entry<String, Territory> item : territories.entrySet()) {
            Territory t = item.getValue();
            Point tCapital = t.getCapital();
            List<Territory> neighboursToDraw = t.getNeighbours();

            for (Territory neighbour : neighboursToDraw) {
                Point nCapital = neighbour.getCapital();
                if((tCapital.getX() > nCapital.getX() && (tCapital.getX() - nCapital.getX()) > this.getWidth() / 2) ||
                        (nCapital.getX() > tCapital.getX() && (nCapital.getX() - tCapital.getX()) > this.getWidth() / 2)){
                    if(nCapital.getY() == tCapital.getY()){
                        g2d.drawLine((int) tCapital.getX(), (int) tCapital.getY(), 0, (int) nCapital.getY());
                        g2d.drawLine((int) nCapital.getX(), (int) nCapital.getY(), this.getWidth(), (int) nCapital.getY());
                    }
                    else {
                        Point left = nCapital;
                        Point right = tCapital;
                        if (tCapital.getX() < nCapital.getX()) {
                            left = tCapital;
                            right = nCapital;
                        }
                        double x = ((left.getY() - right.getY()) * left.getX()) / (left.getX() + this.getWidth() - right.getX());
                        if (left.getY() < right.getY()) {
                            g2d.drawLine((int) left.getX(), (int) left.getY(), 0, (int) (left.getY() - x));
                            g2d.drawLine((int) right.getX(), (int) right.getY(), this.getWidth(), (int) (left.getY() + x));
                        }
                        else{
                            g2d.drawLine((int) left.getX(), (int) left.getY(), 0, (int) (right.getY() + x));
                            g2d.drawLine((int) right.getX(), (int) right.getY(), this.getWidth(), (int) (right.getY() + x));
                        }
                    }

                }else {
                    g2d.drawLine((int) tCapital.getX(), (int) tCapital.getY(), (int) nCapital.getX(), (int) nCapital.getY());
                }
            }
        }

        // Draw Territories (Patches and Capitals)
        for (Map.Entry<String, Territory> t : territories.entrySet()) {
            t.getValue().drawInContext(g2d);
        }
        // Draw the hovered territory again, so it is on top
        Territory hoveredTerritory = GameController.getInstance().getHoveredTerritory();
        if(hoveredTerritory != null)
            hoveredTerritory.drawInContext(g2d);
    }
}
