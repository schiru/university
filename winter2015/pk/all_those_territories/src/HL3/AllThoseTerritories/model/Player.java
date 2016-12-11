package HL3.AllThoseTerritories.model;

import HL3.AllThoseTerritories.GameController;
import HL3.AllThoseTerritories.MoveAndAttackController;
import HL3.AllThoseTerritories.StatusTextTemplates;

import java.awt.*;
import java.awt.event.MouseEvent;

public abstract class Player {
    protected Color color;
    protected int numberOfTerritories;
    protected int currentReinforcements;
    protected GameController game = GameController.getInstance();
    protected String name;
    protected MoveAndAttackController mac;

    public Player(Color color, String name){
        this.color = color;
        this.numberOfTerritories = 0;
        this.name = name;
        this.mac = new MoveAndAttackController(this);
    }

    public Color getColor() {
        return color;
    }
    public String getName(){
        return name;
    }

    public void incNumberOfTerritories(){
        numberOfTerritories++;
    }
    public void decNumberOfTerritories() {
        numberOfTerritories--;
    }

    public void calculateReinforcements(){
        currentReinforcements = numberOfTerritories / 3;
        int bonus = game.getContinentBonusForPlayer(this);
        currentReinforcements += bonus;
        game.changeStatusText(StatusTextTemplates.GET_REINFORCEMENTS, new String[]{"" + currentReinforcements, "" + numberOfTerritories, "" + (numberOfTerritories / 3), "" + bonus});
    }

    public abstract void handleTerritoryClick(Territory t, MouseEvent e);
    public abstract void makeCurrentPlayer();
}
