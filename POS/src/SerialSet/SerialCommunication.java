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
            if (isConnected()) {
                System.err.println("Already connected. Disconnect first before reconnecting.");
                return false;
            }

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
            serialPort = null; // 연결 후 포트 리소스 정리
            System.out.println("Disconnected from serial port");
        }
    }

    public void sendData(byte[] data) {
        if (serialPort != null && serialPort.isOpen()) {
            try {
                serialPort.getOutputStream().write(data);
                serialPort.getOutputStream().flush();
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
                int numRead = serialPort.getInputStream().read(buffer);
                return Arrays.copyOf(buffer, numRead);
            } catch (Exception e) {
                System.err.println("Error receiving data: " + e.getMessage());
            }
        } else {
            System.err.println("Serial port is not open. Cannot receive data.");
        }
        return new byte[0];
    }

    public void sendCutCommand() {
        byte[] cutCommand = {0x1d, 'V', 1};  // ESC/POS 절단 명령어
        sendData(cutCommand);
    }

    public void clearBuffer() {
        if (serialPort != null && serialPort.isOpen()) {
            serialPort.flushIOBuffers();
            System.out.println("Buffers cleared.");
        } else {
            System.err.println("Serial port is not open. Cannot clear buffers.");
        }
    }

}
