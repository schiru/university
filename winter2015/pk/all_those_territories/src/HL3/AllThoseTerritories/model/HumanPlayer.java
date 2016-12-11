package HL3.AllThoseTerritories.model;

import HL3.AllThoseTerritories.GamePhase;
import HL3.AllThoseTerritories.StatusTextTemplates;

import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseEvent;

public class HumanPlayer extends Player {

    public HumanPlayer(Color color, String name){
        super(color, name);
    }

    @Override
    public void handleTerritoryClick(Territory t, MouseEvent e) {
        switch (game.getCurrentPhase()) {
            case LAND_ACQUISITION:
                if (t.getOwner() == null) {
                    // Just a quick and dirty click implementation to show
                    // how it would be done.
                    // TODO: Needs to be incoorporated into the Game Loop
                    // TODO: Change player dynamically
                    t.setOwner(this);
                    t.incArmysize(1);
                    game.nextPlayer();
                }
                break;
            case REINFORCE:
                if (t.getOwner() == this) {
                    t.incArmysize(1);
                    currentReinforcements--;
                    if(currentReinforcements > 0){
                        game.changeStatusText(StatusTextTemplates.REINFORCEMENTS_LEFT, new String[]{"" + currentReinforcements});
                    }
                    else{
                        game.nextPlayer();
                    }
                }
                break;
            case ATTACK:
                // Clicked on owned territory: move or select
                if (t.getOwner() == this) {
                    if (SwingUtilities.isRightMouseButton(e)) {
                        if (mac.isMovePossible(t)) {
                            if (mac.isMoveAllowed(t)) {
                                mac.move(t);
                            } else {
                                // TODO: message: this move is not allowed
                            }
                        } else {
                            // TODO: message: this move is not possible (not neighbouring or not enough armies)
                        }
                    } else if (SwingUtilities.isLeftMouseButton(e)) {
                        if (mac.isMovingArmiesAfterAttackAllowed(t)) {
                            mac.move(t);
                        } else {
                            mac.selectTerritory(t);
                        }
                    }
                }

                // Clicked on foreign territory: ATTACK!!1 (if possible ;-))
                else {
                    mac.attack(t);
                }
        }
    }

    @Override
    public void makeCurrentPlayer() {
        if (game.getCurrentPhase() == GamePhase.REINFORCE){
            calculateReinforcements();
        } else if (game.getCurrentPhase() == GamePhase.ATTACK) {
            mac.reset();
        }
    }
}
