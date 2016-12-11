package HL3.AllThoseTerritories.model;

import java.util.List;

/**
 * Created by lukas on 06/01/16.
 */
public class Continent {
    private String name;
    private int bonus;
    private List<Territory> territories;

    public Continent(String name, int bonus, List<Territory> territories){
        this.name = name;
        this.bonus = bonus;
        this.territories = territories;
    }

    public List<Territory> getTerritories() {
        return territories;
    }

    public boolean containsTerritory(Territory t) {
        return territories.indexOf(t) > -1;
    }

    public int getBonus(){
        return bonus;
    }

    public Player getOwner(){
        Player owner = null;
        for(Territory item : territories){
            if(owner == null) {
                owner = item.getOwner();
            }
            else{
                if(owner != item.getOwner())
                    return null;
            }
        }
        return owner;
    }
}
