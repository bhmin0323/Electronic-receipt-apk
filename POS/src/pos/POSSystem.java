package pos;


import SerialSet.*;
import javax.swing.*;

public class POSSystem {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            SettingsManager settingsManager = new SettingsManager("settings.ini");
            SerialCommunication serialComm = new SerialCommunication(settingsManager);
            Inventory inventory = new Inventory();
            POSUI ui = new POSUI(settingsManager, serialComm, inventory);
            ui.setVisible(true);
        });
    }
}