package SerialSet;

import com.fazecast.jSerialComm.*;

import java.util.Arrays;

public class SerialCommunication {
    private SerialPort serialPort;
    private SettingsManager settingsManager;

    public SerialCommunication(SettingsManager settingsManager) {
        this.settingsManager = settingsManager;
    }

    public boolean connect() {
        try {
            String portName = settingsManager.getPort();
            int baudRate = settingsManager.getRate();

            if (!portName.matches("COM[1-9]")) {
                System.err.println("Invalid port. Must be COM2 to COM9.");
                return false;
            }

            serialPort = SerialPort.getCommPort(portName);
            serialPort.setBaudRate(baudRate);

            // 기본 설정
            serialPort.setNumDataBits(8);
            serialPort.setNumStopBits(1);
            serialPort.setParity(SerialPort.NO_PARITY);
            serialPort.setFlowControl(SerialPort.FLOW_CONTROL_DISABLED);

            if (serialPort.openPort()) {
                System.out.println("Connected to " + portName + " at " + baudRate + " baud");
                return true;
            } else {
                System.err.println("Failed to open port " + portName);
                return false;
            }
        } catch (Exception e) {
            System.err.println("Error connecting to serial port: " + e.getMessage());
            return false;
        }
    }

    public boolean isConnected() {
        return serialPort != null && serialPort.isOpen();
    }

    public void disconnect() {
        if (serialPort != null && serialPort.isOpen()) {
            serialPort.closePort();
            System.out.println("Disconnected from serial port");
        }
    }

    public void sendData(byte[] data) {
        if (serialPort != null && serialPort.isOpen()) {
            try {
                serialPort.getOutputStream().write(data);
                serialPort.getOutputStream().flush();
                System.out.println("Data sent: " + bytesToHex(data));
            } catch (Exception e) {
                System.err.println("Error sending data: " + e.getMessage());
            }
        } else {
            System.err.println("Serial port is not open. Cannot send data.");
        }
    }

    public byte[] receiveData() {
        if (serialPort != null && serialPort.isOpen()) {
            try {
                byte[] buffer = new byte[1024];
                int bytesRead = serialPort.getInputStream().read(buffer);
                if (bytesRead > 0) {
                    byte[] receivedData = Arrays.copyOf(buffer, bytesRead);
                    System.out.println("Data received: " + bytesToHex(receivedData));
                    return receivedData;
                }
            } catch (Exception e) {
                System.err.println("Error receiving data: " + e.getMessage());
            }
        } else {
            System.err.println("Serial port is not open. Cannot receive data.");
        }
        return new byte[0];
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X ", b));
        }
        return sb.toString();
    }
}