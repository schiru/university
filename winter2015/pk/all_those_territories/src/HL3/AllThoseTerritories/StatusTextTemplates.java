package HL3.AllThoseTerritories;

/**
 * Templates for the status Text fields
 * Using the getString method any occurrence of a string in the form of <.*>
 * is replaced with an element supplied to the method in the data array
 */
public enum StatusTextTemplates {
    CLEAR(""),
    LAND_ACQUISITION("Choose a free Territory"),
    GET_REINFORCEMENTS("You get <noReinforcements> Reinforcements: <noTerritories> Territories / 3 = <noReinforcementsFromTerritory> + Continentbonus: <totalBonus>"),
    REINFORCEMENTS_LEFT("You have <currentReinforcements> reinforcements left!"),
    ATTACK_RESULTS("<attackinPlayerName> attacked <attackedTerritory> from <attackingTerritory>. Results: attacking: <attackingDiceResults> defending: <defendingDiceResults>"),
    ENDED("The game has ended. <WinningPlayerName> won!");

    private String template;

    private StatusTextTemplates(String template){
        this.template = template;
    }

    public String getString(String[] data){
        String[] templateArr = template.split("<[^>]*>");
        String text = "";
        if(templateArr != null && data != null) {
            for(int i = 0; i < templateArr.length; i++){
                if(i < data.length) {
                    text += templateArr[i];
                    text += data[i];
                }
                else{
                    text += templateArr[i];
                    break;
                }
            }
        }
        return text;
    }
}
