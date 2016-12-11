package HL3.AllThoseTerritories.model;

import HL3.AllThoseTerritories.StatusTextTemplates;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.Collections;

public class AIPlayer extends Player {

    private ArrayList<Territory> ownedTerritories = new ArrayList<>();
    private Timer timer;
    private int delay = 500;

    public AIPlayer(Color color, String name){
        super(color, name);
    }

    /**
     * Remove territories that have been acquired by others
     * in the meantime
     */
    private void updateOwnedTerritories() {
        ArrayList<Territory> territoriesToRemove = new ArrayList<Territory>();
        for (Territory t : ownedTerritories) {
            if (t.getOwner() != this)
                territoriesToRemove.add(t);
        }
        for(Territory t : territoriesToRemove){
            ownedTerritories.remove(t);
        }
    }

    public void removeFromOwnedTerritories(Territory t){
        ownedTerritories.remove(t);
    }

    public void addOwnedTerritory(Territory t) {
        ownedTerritories.add(t);
    }

    @Override
    public void handleTerritoryClick(Territory t, MouseEvent e) {
        switch (game.getCurrentPhase()) {
            case LAND_ACQUISITION:
                break;
            case REINFORCE:
                break;
            case ATTACK:
        }
    }

    private Territory findLandToAcquire() {
        //updateOwnedTerritories();

        // 1. Try to acquire neighbours
        // Find an unacquired neighbour
        for (Territory t : ownedTerritories) {
            for (Territory n : t.getNeighbours()) {
                if (n.getOwner() == null) {
                    return n;
                }
            }
        }

        // 2. Acquire random territory
        ArrayList<Territory> unaquiredTerritories = game.getUnacquiredTerritories();
        int randomIndex = (int) Math.round(Math.random() * (double) (unaquiredTerritories.size() - 1));
        return unaquiredTerritories.get(randomIndex);
    }

    // Find a neighbouring territory with a different owner, ownedTerritories are shuffled so different territories can be returned
    private Territory findLandToReinforce(){
        //updating should now happen every time territory.setOwner is called
        //updateOwnedTerritories();

        Collections.shuffle(ownedTerritories);

        for (Territory t : ownedTerritories) {
            for (Territory n : t.getNeighbours()) {
                if (n.getOwner() != this) {
                    return t;
                }
            }
        }
        return ownedTerritories.get(0);
    }

    private void acquireLand() {
        Territory eureka = findLandToAcquire();

        if (eureka != null) {
            eureka.setOwner(this);
            eureka.incArmysize(1);
            //addOwnedTerritory(eureka);
        } else {
            System.out.println("Houston, we have a problem. (found no land to aquire)");
            // TODO: can this case even happen?
        }
    }

    private void reinforceLand(){
        findLandToReinforce().incArmysize(1);
        currentReinforcements --;
        if(currentReinforcements > 0) {
            game.changeStatusText(StatusTextTemplates.REINFORCEMENTS_LEFT, new String[]{"" + currentReinforcements});
            delayAction(delay, e -> {
                reinforceLand();
                game.repaint();
            });
        }
        else{
            game.nextPlayer();
        }
    }

    //attacks an enemy territory next to the territory with the most armies
    private void attackLand(){
        Territory maxArmiesTerritory = ownedTerritories.get(0);
        for(Territory t : ownedTerritories){
            if(t.getArmysize() > maxArmiesTerritory.getArmysize() && t.hasEnemyNeighbours(this)){
                maxArmiesTerritory = t;
            }
        }
        mac.selectTerritory(maxArmiesTerritory);
        for(Territory neighbor : maxArmiesTerritory.getNeighbours()){
            if(neighbor.getOwner() != this){
                attackRecklessly(neighbor);
                return;
            }
        }
        // pretty rare case: ownedTerritories.get(0) has the most armies and no neighbouring Territories owned by an enemy
        moveArmies();
    }

    //Keeps on attacking the targeted territory until the battle is won or attacking is no longer possible (only one army left)
    private void attackRecklessly(Territory target){
        if(mac.isAttackPossible(target)){
            mac.attack(target);
            if(mac.getWon()){
                delayAction(delay, e -> {
                    moveAfterAttack(target);
                    game.repaint();
                });
            }
            else{
                delayAction(delay, e -> {
                    attackRecklessly(target);
                    game.repaint();
                });
            }
        }
        else{
            delayAction(delay, e -> {
                moveArmies();
            });
        }
    }

    //moves armies depending on the neighbors of both territories according to the following rules
    //neither territory has enemy territories as neighbors: do not move any armies
    //only the attacking territory has enemy neighbors:     do not move any armies
    //only the conquered territory has enemy neighbors:     move all armies
    //both territories have enemy neighbors:                move the armies so that the same amount is in both territories
    private void moveAfterAttack(Territory target){
        Territory from = mac.getSelectedTerritory();
        boolean finished = false;
        if(mac.isMovingArmiesAfterAttackAllowed(target)){
            if(!target.hasEnemyNeighbours(this)){
                finished = true;
            }
            else if(!from.hasEnemyNeighbours(this)){
                mac.move(target);
                delayAction(delay, e -> {
                    moveAfterAttack(target);
                    game.repaint();
                });
            }
            else{
                if((from.getArmysize() - 1) > target.getArmysize()){
                    mac.move(target);
                    delayAction(delay, e -> {
                        moveAfterAttack(target);
                        game.repaint();
                    });
                }
                else{
                    finished = true;
                }
            }
        }
        else{
            finished = true;
        }
        if(finished){
            delayAction(delay, e -> {
                moveArmies();
            });
        }
    }

    //move armies from a territory with no enemy neighbors to a neighboring territory with enemy neighbors, or to a random neighbor
    private void moveArmies(){
        for(Territory t : ownedTerritories){
            if(t.getArmysize() > 1 && !t.hasEnemyNeighbours(this)){
                mac.selectTerritory(t);
                int randomIndex = (int) Math.round(Math.random() * (double) (t.getNeighbours().size() - 1));
                Territory target = t.getNeighbours().get(randomIndex);

                //find territory to move to
                for(Territory neighbor : t.getNeighbours()){
                    if(neighbor.hasEnemyNeighbours(this)){
                        target = neighbor;
                        break;
                    }
                }

                moveAllArmies(target);
                return;
            }
        }
        mac.reset();
        game.nextPlayer();
    }

    private void moveAllArmies(Territory target){
        if(mac.isMovePossible(target) && mac.isMoveAllowed(target)){
            mac.move(target);
            delayAction(delay, e -> {
                moveAllArmies(target);
            });
        }
        else{
            mac.reset();
            game.nextPlayer();
        }
    }

    private void delayAction(int milliseconds, ActionListener callback) {
        timer = new Timer(milliseconds, e -> {
            timer.stop();
            callback.actionPerformed(e);

        });

        timer.start();
    }


    @Override
    public void makeCurrentPlayer() {
        switch (game.getCurrentPhase()) {
            case LAND_ACQUISITION:
                delayAction(delay, e -> {
                    acquireLand();
                    game.repaint();
                    game.nextPlayer();
                });
                break;
            case REINFORCE:
                calculateReinforcements();
                delayAction(delay, e -> {
                    reinforceLand();
                    game.repaint();
                });
                break;
            case ATTACK:
                mac.reset();
                delayAction(delay, e -> {
                    attackLand();
                    game.repaint();
                });
        }
    }
}
