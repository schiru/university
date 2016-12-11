package HL3.AllThoseTerritories;

import HL3.AllThoseTerritories.model.Player;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class MenuBar extends JMenuBar implements ActionListener {
    JButton restartButton = new JButton("Restart Game");
    JButton nextRoundButton = new JButton("End Turn");
    JLabel currentPlayerLabel = new JLabel("Player", SwingConstants.CENTER);
    JLabel currentPhaseLabel = new JLabel("Phase", SwingConstants.CENTER);

    public MenuBar() {
        setLayout(new GridLayout(1, 4));

        add(restartButton);
        add(currentPlayerLabel);
        add(currentPhaseLabel);
        add(nextRoundButton);

        restartButton.addActionListener(this);
        nextRoundButton.addActionListener(this);
        nextRoundButton.setEnabled(false);
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        if(e.getSource() == restartButton){
            GameController.restart();
        }
        else if(e.getSource() == nextRoundButton){
            GameController.getInstance().nextPlayer();
        }
    }

    public void setNextRoundButtonActive(boolean active){
        nextRoundButton.setEnabled(active);
    }

    public void setPlayerLabel(Player currentPlayer){
        currentPlayerLabel.setText(currentPlayer.getName());
        currentPlayerLabel.setForeground(currentPlayer.getColor());
    }

    public void setPhaseLabel(GamePhase phase){
        currentPhaseLabel.setText(phase.toString());
    }
}
