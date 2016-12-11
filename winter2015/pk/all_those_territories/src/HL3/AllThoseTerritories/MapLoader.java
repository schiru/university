package HL3.AllThoseTerritories;

import HL3.AllThoseTerritories.model.Continent;
import HL3.AllThoseTerritories.model.Patch;
import HL3.AllThoseTerritories.model.Territory;

import java.awt.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * A class for parsing the Mapfiles
 */
public class MapLoader {
    private static List<Patch> patches;
    private static Map<String, Territory> territories;
    private static Map<String, Continent> continents;
    private static String savedFileName;
    public static void load(String filename){
        patches = GameController.getInstance().getPatches();
        territories = GameController.getInstance().getTerritories();
        continents = GameController.getInstance().getContinents();

        if (filename.equals(""))
            filename = savedFileName;
        else
            savedFileName = filename;

        try {
            List<String> mapfile = Files.readAllLines(Paths.get("maps/" + filename + ".map"));
            for(String line : mapfile){
                readLine(line);
            }
        }
        catch (Exception ex){
            System.err.println("Error reading Mapfile!");
            System.exit(1);
        }
    }

    // calls a method corresponding to the command in the current line
    private static void readLine(String line){
        String[] lineArr = line.split(" ");
        switch (lineArr[0]){
            case "patch-of": patchOf(lineArr); break;
            case "capital-of": capitalOf(lineArr); break;
            case "neighbors-of": neighborsOf(lineArr); break;
            case "continent": continent(lineArr); break;
            default: ;
        }
    }

    //TODO: more validation for all methods

    private static void patchOf(String[] lineArr){
        String name = extractName(lineArr);
        int namelength = name.split(" ").length;

        if(territories.get(name) == null){
            territories.put(name, new Territory(name));
        }
        List<Point> points = new ArrayList<Point>();
        for(int i = 1 + namelength; i < lineArr.length; i = i + 2){
            int x = Integer.parseInt(lineArr[i]);
            int y = Integer.parseInt(lineArr[i + 1]);
            Point p = new Point(x, y);
            points.add(p);
        }
        Patch newPatch = new Patch(points);
        patches.add(newPatch);
        territories.get(name).addPatch(newPatch);
    }

    private static void capitalOf(String[] lineArr){
        String name = extractName(lineArr);
        int namelength = name.split(" ").length;

        if(territories.get(name) == null){
            territories.put(name, new Territory(name));
        }
        int x = Integer.parseInt(lineArr[1 + namelength]);
            int y = Integer.parseInt(lineArr[2 + namelength]);
            if(3 + namelength != lineArr.length){
                    throw new RuntimeException();
                }
            territories.get(name).setCapital(new Point(x, y));
    }

    private static void neighborsOf(String[] lineArr){
        String name = extractName(lineArr);
        int namelength = name.split(" ").length;

        if(lineArr[1 + namelength].equals(":")){
            for(int i = 2 + namelength; i < lineArr.length; i = i + 1){
                String neighborTerr = extractNameFrom(lineArr, i);
                territories.get(name).addNeighbour(territories.get(neighborTerr));
                territories.get(neighborTerr).addNeighbour(territories.get(name));
                i = i + neighborTerr.split(" ").length;
            }
        }
        else{
            throw new RuntimeException();
        }
    }

    private static void continent(String[] lineArr){
        String name = extractName(lineArr);
        int namelength = name.split(" ").length;

        int bonus = Integer.parseInt(lineArr[1 + namelength]);

        List<Territory> territories = new ArrayList<Territory>();

        if(lineArr[2 + namelength].equals(":")){
            for(int i = 3 + namelength; i < lineArr.length; i = i + 1){
                String territory = extractNameFrom(lineArr, i);
                territories.add(MapLoader.territories.get(territory));
                i = i + territory.split(" ").length;
            }
        }
        else{
            throw new RuntimeException();
        }

        continents.put(name, new Continent(name, bonus, territories));
    }

    // returns the name of a territory or continent at the beginning of a line
    private static String extractName(String[] lineArr){
        return extractNameFrom(lineArr, 1);
    }

    private static String extractNameFrom(String[] lineArr, int from){
        String name = "";
        if(!(lineArr[from].matches("\\d+") || lineArr[from].equals(":") || lineArr[from].equals("-"))){
            name += lineArr[from];
        }
        for(int i = from + 1; i < lineArr.length; i++){
            if(!(lineArr[i].matches("\\d+") || lineArr[i].equals(":") || lineArr[i].equals("-"))){
                name += " " + lineArr[i];
            }
            else{
                break;
            }
        }
        return name;
    }
}
