package HL3.AllThoseTerritories;

import HL3.AllThoseTerritories.model.Player;
import HL3.AllThoseTerritories.model.Territory;

import java.util.ArrayList;
import java.util.Collections;

/**
 * Created by thomas on 29/01/16.
 */
public class MoveAndAttackController {
    // Tells to which player this instance belongs to
    private Player player = null;

    // Each round, the user is only allowed to move armies between two owned territories
    private ArrayList<Territory> allowedMoveTerritories = new ArrayList<>();

    // Each round, the user is only allowed to repeat an attack between the same two territorries
    private ArrayList<Territory> allowedAttackTerritories = new ArrayList<>(2);

    // Holds the acquired territory after a successful attack
    private Territory attackWinner = null;
    private Territory acquiredTerritory = null;

    private Territory selectedTerritory = null;

    public MoveAndAttackController(Player player) {
        this.player = player;
    }

    public void selectTerritory(Territory t) {
        if (selectedTerritory != null) {
            selectedTerritory.setSelected(false);
        }

        selectedTerritory = t;

        t.setSelected(true);

        // If a different territory gets selected after a successful attack,
        // it's no longer possible to move armies to the acquired territory
        attackWinner = null;
    }

    public boolean isMovePossible(Territory t) {
        if (selectedTerritory == null
                || !t.isNeighbourOf(selectedTerritory)
                || selectedTerritory.getArmysize() == 1)
            return false;

        return true;
    }

    public boolean isMoveAllowed(Territory t) {
        // No move has happend before
        // or t and selectedTerritory are two territory that were previously (in this round)
        // used for moving
        return allowedMoveTerritories.size() == 0
                || (allowedMoveTerritories.indexOf(t) > -1
                    && allowedMoveTerritories.indexOf(selectedTerritory) > -1);
    }

    public boolean isAttackPossible(Territory territory) {
        // If there player has already attacked in his current turn,
        // he's only allowed to perform the same attack again, but no other one.
        if (allowedAttackTerritories.size() == 0
                || (allowedAttackTerritories.get(0) == selectedTerritory
                    && allowedAttackTerritories.get(1) == territory)) {
            return acquiredTerritory == null && selectedTerritory != null && selectedTerritory.getArmysize() > 1;
        }

        return false;
    }

    // When the current turn is over, prepare for the next one..
    public void reset() {
        allowedMoveTerritories = new ArrayList<>();
        allowedAttackTerritories = new ArrayList<>();
        attackWinner = null;
        acquiredTerritory = null;

        if (selectedTerritory != null) {
            selectedTerritory.setSelected(false);
            selectedTerritory = null;
        }
    }

    public boolean isMovingArmiesAfterAttackAllowed(Territory t) {
        return selectedTerritory == attackWinner
                && t == acquiredTerritory
                && isMovePossible(t);
    }

    public boolean move(Territory t) {
        if (isMovePossible(t)) {
            if (isMovingArmiesAfterAttackAllowed(t)) {
                selectedTerritory.moveArmies(t, 1);
                return true;
            } else if (isMoveAllowed(t)) {
                selectedTerritory.moveArmies(t, 1);

                allowedMoveTerritories.add(selectedTerritory);
                allowedMoveTerritories.add(t);
                return true;
            }
        }
        return false;
    }

    private int calculateAttackingArmies(int armySize) {
        switch (armySize) {
            case 2: return 1;
            case 3: return 2;
            default: return 3;
        }
    }

    private ArrayList<Integer> rollDices(int n) {
        ArrayList<Integer> result = new ArrayList<>();

        for (int i = 0; i < n; i++) {
            result.add(((int)(Math.random() * 6)) + 1);
        }

        return result;
    }

    private int popMaxDiceValue(ArrayList<Integer> dices) {
        int max = Collections.max(dices);
        dices.remove(new Integer(max));

        return max;
    }

    public void attack(Territory t) {
        if (isAttackPossible(t)) {
            Territory attacker = selectedTerritory;
            Territory defender = t;

            allowedAttackTerritories.add(0, attacker);
            allowedAttackTerritories.add(1, defender);

            int attackingArmies = calculateAttackingArmies(attacker.getArmysize());
            // how many armies the attacker lost
            int attackerLosses = 0;
            int defendingArmies = Math.min(2, defender.getArmysize()); // 1 or 2
            // how many armies the defender lost
            int defenderLosses = 0;

            ArrayList<Integer> attackerDices = rollDices(attackingArmies);
            ArrayList<Integer> defenderDices = rollDices(defendingArmies);

            GameController.getInstance().changeStatusText(StatusTextTemplates.ATTACK_RESULTS, new String[]{attacker.getOwner().getName(), defender.getName(), attacker.getName(), attackerDices.toString(), defenderDices.toString()});

            // Continue until one of both sides has no armies left
            // or until there are no more dice values to compare
            while (attackingArmies > 0 && defendingArmies > 0
                    && attackerDices.size() > 0 && defenderDices.size() > 0) {
                int attackerMaxDiceValue = popMaxDiceValue(attackerDices);
                int defenderMaxDiceValue = popMaxDiceValue(defenderDices);

                if (defenderMaxDiceValue >= attackerMaxDiceValue) {
                    attackingArmies--;
                    attackerLosses++;
                } else {
                    defendingArmies--;
                    defenderLosses++;
                }
            }

            attacker.incArmysize(-attackerLosses);
            defender.incArmysize(-defenderLosses);

            if (defender.getArmysize() == 0 && attackingArmies > 0) {
                defender.setOwner(attacker.getOwner());

                // the winning armies obtain the new land
                defender.setArmysize(attackingArmies);
                // subtract armies that moved to newly acquired land
                attacker.incArmysize(-attackingArmies);

                attackWinner = attacker;
                acquiredTerritory = defender;
            }
        }
    }

    public Territory getSelectedTerritory(){
        return selectedTerritory;
    }

    public boolean getWon(){
        return attackWinner == selectedTerritory;
    }
}
