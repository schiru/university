package HL3.AllThoseTerritories.model;

import HL3.AllThoseTerritories.GameController;

import java.awt.*;
import java.util.ArrayList;
import java.util.List;

public class Territory {
    private String name;
    private Point capital;
    private int armysize;
    private Player owner;
    private List<Patch> patches;
    private List<Territory> neighbours;

    public Territory(String name){
        this.name = name;
        patches = new ArrayList<Patch>();
        neighbours = new ArrayList<Territory>();
    }

    public void setCapital(Point capital){
        this.capital = capital;
    }

    public void setArmysize(int n){
        this.armysize = n;

        GameController.getInstance().repaint();
    }

    public void incArmysize(int n){
        armysize += n;

        GameController.getInstance().repaint();
    }

    public int getArmysize() {
        return armysize;
    }

    public void setOwner(Player owner){
        if(this.owner instanceof AIPlayer){
            AIPlayer AIOwner = (AIPlayer) this.owner;
            AIOwner.removeFromOwnedTerritories(this);
        }
        if(this.owner != null) {
            this.owner.decNumberOfTerritories();
            if(this.owner.numberOfTerritories == 0){
                GameController.getInstance().removePlayer(this.owner);
            }
        }

        this.owner = owner;
        this.owner.incNumberOfTerritories();

        if(this.owner instanceof AIPlayer){
            AIPlayer AIOwner = (AIPlayer) this.owner;
            AIOwner.addOwnedTerritory(this);
        }

        for (Patch patch : patches) {
            patch.setColor(owner.getColor());
        }

        GameController.getInstance().repaint();
    }

    public void addPatch(Patch newPatch){
        patches.add(newPatch);
    }

    public void addNeighbour(Territory neighbour){
        if(!neighbours.contains(neighbour))
            neighbours.add(neighbour);
    }

    public List<Territory> getNeighbours() { return neighbours; }

    public Point getCapital() {
        return capital;
    }

    // Draws the individual patches of the territory
    // onto a given graphics context
    // (in this case this should be the main MapView context)
    public void drawInContext(Graphics2D g2d) {
       for (Patch patch : patches) {
           patch.drawInContext(g2d);
       }

        drawCapital(g2d);
    }

    private void drawCapital(Graphics2D g2d) {
        if(capital == null) return;

        g2d.setFont(new Font("Arial", Font.BOLD, 13));

        g2d.drawString(armysize + "", (float) capital.getX(), (float) capital.getY());
    }

    public boolean containsPoint(Point point) {
        for (Patch patch : patches) {
            if (patch.containsPoint(point))
                return true;
        }

        return false;
    }

    public boolean isNeighbourOf(Territory other) {
        return neighbours.indexOf(other) > -1;
    }

    public boolean moveArmies(Territory destination, int n) {
        if (this.armysize >= 1 + n) {
            armysize -= n;
            destination.incArmysize(n);
            return true;
        }

        return false;
    }

    public Player getOwner(){
        return owner;
    }

    public String getName(){
        return name;
    }

    public void setSelected(boolean hovered){
        for(Patch element : patches){
            element.setSelected(hovered);
        }

        GameController.getInstance().repaint();
    }

    public void setHover(boolean hovered){
        for(Patch element : patches){
            element.setHovered(hovered);
        }
        GameController.getInstance().repaint();
    }

    public boolean hasEnemyNeighbours(Player player){
        for(Territory neighbour : this.neighbours){
            if(neighbour.getOwner() != player){
                return true;
            }
        }
        return false;
    }
}