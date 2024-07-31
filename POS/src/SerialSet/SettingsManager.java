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
        properties.setProperty("port", "COM1");
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
        return properties.getProperty("port", "COM1");
    }

    public int getRate() {
        return Integer.parseInt(properties.getProperty("rate", "115200"));
    }

    public void setPort(String port) {
        properties.setProperty("port", port);
        saveSettings();
    }

    public void setRate(int rate) {
        properties.setProperty("rate", String.valueOf(rate));
        saveSettings();
    }
}