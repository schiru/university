package HL3.AllThoseTerritories;

import HL3.AllThoseTerritories.model.*;

import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.*;
import java.util.List;

public class GameController extends JFrame implements MouseListener, MouseMotionListener{

    /*
        starting the game
        args[0] has to be the name of a map file located in maps/ without the .map extension
            example: world for maps/world.map
        TODO: maybe let the user specify a complete filename
     */
    public static void main(String[] args) {
        GameController.getInstance().setup(args[0]);
    }

    // STATIC FUNCTIONS AND VARIABLES

    private static GameController instance;

    public static GameController getInstance(){
        if (instance == null) {
            instance = new GameController();
        }

        return instance;
    }

    public static void restart(){
        GameController game = GameController.getInstance();
        game.setVisible(false);
        game.dispose();

        instance = null;
        GameController.getInstance().setup("");
    }

    // MEMBER FUNCTIONS AND VARIABLES

    private List<Player> players;
    private List<Patch> patches;
    private Map<String, Territory> territories;
    private Map<String, Continent> continents;
    private MapView map;
    private int currentPlayer;
    private GamePhase phase;
    private MenuBar menu;
    private UIBottomBar bottomBar;
    private Territory hoveredTerritory;


    private GameController(){
        players = new LinkedList<Player>();
        patches = new ArrayList<Patch>();
        territories = new HashMap<String, Territory>();
        continents = new HashMap<String, Continent>();
        phase = GamePhase.LAND_ACQUISITION;
    }

    public GamePhase getCurrentPhase() {
        return phase;
    }

    public void setup(String filename){
        players.add(new HumanPlayer(new Color(255, 0, 0), "Player1"));
        players.add(new AIPlayer(new Color(0, 0, 255), "Player2"));
        //players.add(new AIPlayer(Color.GREEN, "Player3"));
        //players.add(new AIPlayer(Color.ORANGE, "Player4"));

        setTitle("Half Life 3");
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        MapLoader.load(filename);
        map = new MapView(territories);

        add(map);

        map.addMouseListener(this);
        map.addMouseMotionListener(this);

        bottomBar = new UIBottomBar();
        add(bottomBar, BorderLayout.SOUTH);

        setupMenuBar();
        pack();

        setVisible(true);

        // necessary if the first player is an AIPlayer
        players.get(0).makeCurrentPlayer();
    }

    private void setupMenuBar() {
        menu = new MenuBar();
        menu.setPlayerLabel(players.get(currentPlayer));
        menu.setPhaseLabel(phase);
        setJMenuBar(menu);
    }

    @Override
    public void mousePressed(MouseEvent e) {
        Territory clickedTerritory = getTerritoryAt(e.getPoint());
        if(clickedTerritory != null)
            players.get(currentPlayer).handleTerritoryClick(clickedTerritory, e);
    }

    @Override
    public void mouseMoved(MouseEvent e) {
        if(hoveredTerritory != null && hoveredTerritory.containsPoint(e.getPoint())){
        }
        else{
            if(hoveredTerritory != null){
                hoveredTerritory.setHover(false);
            }
            Territory t = getTerritoryAt(e.getPoint());
            hoveredTerritory = t;
            if (t != null) {
                t.setHover(true);
                bottomBar.setHoveredTerritoryText(t);
            }
            else{
                bottomBar.resetHoveredTerritoryText();
            }
        }
    }

    public Territory getTerritoryAt(Point position){
        for (Map.Entry<String, Territory> item : territories.entrySet()) {
            Territory t = item.getValue();
            if (t.containsPoint(position)) {
                return t;
            }
        }
        return null;
    }

    public void nextPlayer(){
        boolean isLastPlayer = currentPlayer >= players.size() - 1;

        // Move to next phase if
        // all territories have been selected in land_acquisition mode
        // OR last player was selected in any other mode
        if (!unclaimedLandAvailable() && (isLastPlayer || phase == GamePhase.LAND_ACQUISITION)) {
            nextPhase();
            currentPlayer = 0;
        } else {
            currentPlayer = isLastPlayer ? 0 : currentPlayer + 1;
        }

        Player newPlayer = players.get(currentPlayer);
        menu.setPlayerLabel(newPlayer);
        newPlayer.makeCurrentPlayer();
        if(phase == GamePhase.ATTACK)
            menu.setNextRoundButtonActive(newPlayer instanceof HumanPlayer);
    }

    public void nextPhase() {
        switch (phase) {
            case LAND_ACQUISITION:
                phase = GamePhase.REINFORCE;
                break;
            case REINFORCE:
                phase = GamePhase.ATTACK;
                break;
            case ATTACK:
                phase = GamePhase.REINFORCE;
                menu.setNextRoundButtonActive(false);
                break;
            case COMPLETE:
                break; // TODO: later
        }
        menu.setPhaseLabel(phase);
        bottomBar.setStatusText(StatusTextTemplates.CLEAR, new String[]{});
    }

    public void removePlayer(Player player){
        int index = players.indexOf(player);
        if(index < currentPlayer){
            currentPlayer--;
        }
        players.remove(player);
        if(players.size() == 1){
            phase = GamePhase.COMPLETE;
            menu.setPhaseLabel(phase);
            changeStatusText(StatusTextTemplates.ENDED, new String[]{players.get(0).getName()});
        }
    }

    public boolean unclaimedLandAvailable(){
        for (Map.Entry<String, Territory> item : territories.entrySet()) {
            if(item.getValue().getOwner() == null){
                return true;
            }
        }
        return false;
    }

    public ArrayList<Territory> getUnacquiredTerritories() {
        ArrayList<Territory> un = new ArrayList<>();

        for(Map.Entry<String, Territory> item : territories.entrySet()) {
            Territory t = item.getValue();
            if (t.getOwner() == null)
                un.add(t);
        }

        return un;
    }

    /**
     * May return null if territory does not belong to any continent
     */
    public Continent getContinentForTerritory(Territory t) {
        for(Map.Entry<String, Continent> item : continents.entrySet()) {
            Continent c = item.getValue();
            if (c.containsTerritory(t)) {
                return c;
            }
        }

        return null;
    }

    public int getContinentBonusForPlayer(Player player){
        int bonus = 0;
        for(Map.Entry<String, Continent> item : continents.entrySet()){
            if(item.getValue().getOwner() == player){
                bonus += item.getValue().getBonus();
            }
        }
        return bonus;
    }

    public void changeStatusText(StatusTextTemplates template, String[] data){
        bottomBar.setStatusText(template, data);
    }

    public Territory getHoveredTerritory(){
        return hoveredTerritory;
    }

    public List<Patch> getPatches() {
        return patches;
    }

    public Map<String, Territory> getTerritories() {
        return territories;
    }

    public Map<String, Continent> getContinents() {
        return continents;
    }

    @Override
    public void mouseClicked(MouseEvent e) { }

    @Override
    public void mouseReleased(MouseEvent e) { }

    @Override
    public void mouseEntered(MouseEvent e) { }

    @Override
    public void mouseExited(MouseEvent e) { }

    @Override
    public void mouseDragged(MouseEvent e) { }
}
