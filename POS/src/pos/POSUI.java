package pos;

import SerialSet.*;
import com.fazecast.jSerialComm.SerialPort;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.Arrays;
import java.util.Map;

public class POSUI extends JFrame {
    private SettingsManager settingsManager;
    private SerialCommunication serialComm;
    private Inventory inventory;
    private Sale currentSale;

    private JComboBox<String> portComboBox;
    private JComboBox<String> rateComboBox;
    private JComboBox<String> productComboBox;
    private JSpinner quantitySpinner;
    private JTable saleTable;
    private JLabel totalLabel;

    public POSUI(SettingsManager settingsManager, SerialCommunication serialComm, Inventory inventory) {
        this.settingsManager = settingsManager;
        this.serialComm = serialComm;
        this.inventory = inventory;
        this.currentSale = new Sale();

        setTitle("POS System");
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.addTab("Sales", createSalesPanel());
        tabbedPane.addTab("Settings", createSettingsPanel());

        add(tabbedPane);
    }

    private JPanel createSalesPanel() {
        JPanel panel = new JPanel(new BorderLayout());

        JPanel topPanel = new JPanel(new FlowLayout());
        productComboBox = new JComboBox<>(inventory.getProductNames());

        // JSpinner로 수량 선택 구현
        SpinnerNumberModel spinnerModel = new SpinnerNumberModel(1, 1, 100, 1);
        quantitySpinner = new JSpinner(spinnerModel);

        JButton addButton = new JButton("Add to Sale");
        addButton.addActionListener(e -> addToSale());

        topPanel.add(new JLabel("Product:"));
        topPanel.add(productComboBox);
        topPanel.add(new JLabel("Quantity:"));
        topPanel.add(quantitySpinner);
        topPanel.add(addButton);

        saleTable = new JTable(new DefaultTableModel(new Object[]{"Product", "Price", "Quantity", "Subtotal"}, 0));
        JScrollPane scrollPane = new JScrollPane(saleTable);

        totalLabel = new JLabel("Total: $0.00");
        JButton completeButton = new JButton("Complete Sale");
        completeButton.addActionListener(e -> completeSale());

        JPanel bottomPanel = new JPanel(new FlowLayout());
        bottomPanel.add(totalLabel);
        bottomPanel.add(completeButton);

        panel.add(topPanel, BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(bottomPanel, BorderLayout.SOUTH);

        return panel;
    }

    private JPanel createSettingsPanel() {
        JPanel panel = new JPanel(new GridLayout(3, 2));

        panel.add(new JLabel("Port:"));
        portComboBox = new JComboBox<>(new String[]{"COM1", "COM2", "COM3", "COM4"});
        portComboBox.setSelectedItem(settingsManager.getPort());
        panel.add(portComboBox);

        panel.add(new JLabel("Baud Rate:"));
        rateComboBox = new JComboBox<>(new String[]{"9600", "115200"});
        rateComboBox.setSelectedItem(String.valueOf(settingsManager.getRate()));
        panel.add(rateComboBox);

        JButton saveButton = new JButton("Save Settings");
        saveButton.addActionListener(e -> saveSettings());
        panel.add(saveButton);

        JButton connectButton = new JButton("Connect");
        connectButton.addActionListener(e -> serialComm.connect());
        panel.add(connectButton);

        return panel;
    }

    private void addToSale() {
        String productName = (String) productComboBox.getSelectedItem();
        int quantity = (Integer) quantitySpinner.getValue();

        Product product = inventory.getProduct(productName);
        if (product != null && product.getQuantity() >= quantity) {
            currentSale.addItem(product, quantity);
            inventory.updateQuantity(productName, quantity);
            updateSaleTable();
        } else {
            JOptionPane.showMessageDialog(this, "Insufficient stock!");
        }
    }

    private void updateSaleTable() {
        DefaultTableModel model = (DefaultTableModel) saleTable.getModel();
        model.setRowCount(0);

        for (Map.Entry<Product, Integer> entry : currentSale.getItems().entrySet()) {
            Product product = entry.getKey();
            int quantity = entry.getValue();
            double subtotal = product.getPrice() * quantity;
            model.addRow(new Object[]{product.getName(), product.getPrice(), quantity, String.format("$%.2f", subtotal)});
        }

        totalLabel.setText(String.format("Total: $%.2f", currentSale.getTotal()));
    }

    private void completeSale() {
        if (currentSale.getItems().isEmpty()) {
            JOptionPane.showMessageDialog(this, "No items in the current sale!");
            return;
        }

        String receipt = generateReceipt();
        byte[] receiptData = receipt.getBytes(); // String을 byte 배열로 변환
        serialComm.sendData(receiptData);

        JOptionPane.showMessageDialog(this, "Sale completed and receipt sent to printer!");
        currentSale = new Sale();
        updateSaleTable();
    }

    private String generateReceipt() {
        StringBuilder receipt = new StringBuilder();
        receipt.append("===== POS Receipt =====\n");
        for (Map.Entry<Product, Integer> entry : currentSale.getItems().entrySet()) {
            Product product = entry.getKey();
            int quantity = entry.getValue();
            receipt.append(String.format("%s x%d - $%.2f\n", product.getName(), quantity, product.getPrice() * quantity));
        }
        receipt.append("----------------------\n");
        receipt.append(String.format("Total: $%.2f\n", currentSale.getTotal()));
        receipt.append("======================\n");
        return receipt.toString();
    }

    private void saveSettings() {
        String selectedPort = (String) portComboBox.getSelectedItem();
        int selectedRate = Integer.parseInt((String) rateComboBox.getSelectedItem());

        settingsManager.setPort(selectedPort);
        settingsManager.setRate(selectedRate);

        JOptionPane.showMessageDialog(this, "Settings saved successfully!");
    }
}