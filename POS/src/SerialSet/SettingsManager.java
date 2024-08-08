package SerialSet;

import java.io.*;
import java.util.Properties;

public class SettingsManager {
    private Properties properties;
    private String filename;

    public SettingsManager(String filename) {
        this.filename = filename;
        properties = new Properties();
        loadSettings();
    }

    private void loadSettings() {
        try (FileInputStream in = new FileInputStream(filename)) {
            properties.load(in);
        } catch (IOException e) {
            // 파일이 없으면 기본값 설정
            setDefaultSettings();
        }
    }

    private void setDefaultSettings() {
        properties.setProperty("port", "COM2");
        properties.setProperty("rate", "115200");
        saveSettings();
    }

    public void saveSettings() {
        try (FileOutputStream out = new FileOutputStream(filename)) {
            properties.store(out, "POS System Settings");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String getPort() {
        return properties.getProperty("port", "COM2");
    }

    public int getRate() {
        return Integer.parseInt(properties.getProperty("rate", "115200"));
    }

    public void setPort(String port) {
        if (port.matches("COM[1-9]")) {
            properties.setProperty("port", port);
            saveSettings();
        } else {
            throw new IllegalArgumentException("Invalid port. Must be COM2 to COM9.");
        }
    }

    public void setRate(int rate) {
        properties.setProperty("rate", String.valueOf(rate));
        saveSettings();
    }
}