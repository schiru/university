package HL3.AllThoseTerritories;

import HL3.AllThoseTerritories.model.Territory;

import javax.swing.*;
import java.awt.*;

public class UIBottomBar extends JPanel{
    private JLabel hoveredTerritory;
    private JLabel statusText;
    public UIBottomBar(){
        setLayout(new GridBagLayout());

        hoveredTerritory = new JLabel("", SwingConstants.CENTER);
        GridBagConstraints c = new GridBagConstraints();
        c.weightx = 0.2;
        hoveredTerritory.setPreferredSize(new Dimension(250, 20));
        add(hoveredTerritory, c);

        statusText = new JLabel("status Text", SwingConstants.CENTER);
        c.weightx = 0.8;
        statusText.setPreferredSize(new Dimension(1000, 20));
        add(statusText, c);
        setStatusText(StatusTextTemplates.LAND_ACQUISITION, new String[0]);
    }

    public void setStatusText(StatusTextTemplates template, String[] values){
        statusText.setText(template.getString(values));
    }

    public void setHoveredTerritoryText(Territory t){
        hoveredTerritory.setText(t.getName());
    }

    public void resetHoveredTerritoryText(){
        hoveredTerritory.setText("");
    }
}
