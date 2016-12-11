package HL3.AllThoseTerritories;

/**
 * An enum for the possible GamePhases, which are:
 *      LAND_ACQUISITION: Players take turns choosing their first countries at the start of the game
 *      REINFORCE: distributing reinforcements at the start of a round
 *      ATTACK: attacking and moving the players armies
 *      COMPLETE: someone won and the game has ended
 */
public enum GamePhase {
    LAND_ACQUISITION("Land acquisition"), REINFORCE("Reinforcement"), ATTACK("Attack & Movement"), COMPLETE("The Game has ended");

    private String stringVal;

    private GamePhase(String stringValue){
        this.stringVal = stringValue;
    }

    public String toString(){
        return stringVal;
    }
}
