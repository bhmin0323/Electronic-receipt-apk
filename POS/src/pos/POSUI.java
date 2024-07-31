package pos;

import SerialSet.*;
import com.fazecast.jSerialComm.SerialPort;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.Map;


public class POSUI extends JFrame {
    private SettingsManager settingsManager;
    private SerialCommunication serialComm;
    private Inventory inventory;
    private Sale currentSale;

    private JComboBox<String> portComboBox;
    private JComboBox<String> rateComboBox;
    private JTable saleTable;
    private JLabel totalLabel;

    public POSUI(SettingsManager settingsManager, SerialCommunication serialComm, Inventory inventory) {
        this.settingsManager = settingsManager;
        this.serialComm = serialComm;
        this.inventory = inventory;
        this.currentSale = new Sale();

        setTitle("POS System");
        setSize(1500, 1000);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.addTab("Sales", createSalesPanel());
        tabbedPane.addTab("Settings", createSettingsPanel());

        add(tabbedPane);
    }

    private JPanel createSalesPanel() {
        JPanel panel = new JPanel(new BorderLayout());

        // 제품 목록을 5x5 그리드로 표시
        int rows = 5;
        int cols = 5;
        JPanel productListPanel = new JPanel(new GridLayout(rows, cols, 5, 5)); // 5x5 그리드, 각 버튼 사이에 5px 간격

        // 제품 버튼 추가
        String[] productNames = inventory.getProductNames(); // List<String> 가정
        int totalButtons = rows * cols;
        int productCount = productNames.length;
        int emptySpaces = totalButtons - productCount;

        for (String productName : productNames) {
            JButton productButton = new JButton(productName);
            productButton.addActionListener(e -> showProductDialog(productName));
            productListPanel.add(productButton);
        }

        // 빈 공간을 채우기 위해 빈 JLabel 추가
        for (int i = 0; i < emptySpaces; i++) {
            JLabel emptyLabel = new JLabel(); // 빈 공간을 채우기 위한 JLabel
            emptyLabel.setOpaque(true); // 배경색이 보이도록 설정
            emptyLabel.setBackground(Color.LIGHT_GRAY); // 공백 색상 설정 (선택 사항)
            productListPanel.add(emptyLabel);
        }

        JScrollPane productScrollPane = new JScrollPane(productListPanel);

        // 판매 테이블
        saleTable = new JTable(new DefaultTableModel(new Object[]{"Product", "Price", "Quantity", "Subtotal"}, 0));
        JScrollPane saleScrollPane = new JScrollPane(saleTable);

        // 스플릿 패널
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, productScrollPane, saleScrollPane);
        splitPane.setResizeWeight(0.9); // 제품 목록 30%, 판매 테이블 70%
        splitPane.setDividerLocation(1100); // 초기 분할 위치 (조정 가능)

        totalLabel = new JLabel("Total: $0.00");
        JButton completeButton = new JButton("Complete Sale");
        completeButton.addActionListener(e -> completeSale());

        JPanel bottomPanel = new JPanel(new FlowLayout());
        bottomPanel.add(totalLabel);
        bottomPanel.add(completeButton);

        panel.add(splitPane, BorderLayout.CENTER);
        panel.add(bottomPanel, BorderLayout.SOUTH);

        return panel;
    }


    private JPanel createSettingsPanel() {
        JPanel panel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();

        gbc.insets = new Insets(1, 50, 1, 50); // 여백 설정

        // 포트 라벨과 콤보박스
        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.weightx = 0.3;
        JLabel portLabel = new JLabel("포트:");
        panel.add(portLabel, gbc);

        gbc.gridx = 1;
        gbc.gridy = 0;
        gbc.weightx = 0.7;
        portComboBox = new JComboBox<>(new String[]{"COM1", "COM2", "COM3", "COM4"});
        portComboBox.setSelectedItem(settingsManager.getPort());
        portComboBox.setPreferredSize(new Dimension(100, 50)); // 크기 설정
        panel.add(portComboBox, gbc);

        // 전송 속도 라벨과 콤보박스
        gbc.gridx = 0;
        gbc.gridy = 1;
        gbc.weightx = 0.3;
        JLabel rateLabel = new JLabel("전송 속도:");
        panel.add(rateLabel, gbc);

        gbc.gridx = 1;
        gbc.gridy = 1;
        gbc.weightx = 0.7;
        rateComboBox = new JComboBox<>(new String[]{"9600", "115200"});
        rateComboBox.setSelectedItem(String.valueOf(settingsManager.getRate()));
        rateComboBox.setPreferredSize(new Dimension(100, 50)); // 크기 설정
        panel.add(rateComboBox, gbc);

        // 버튼들
        gbc.gridx = 0;
        gbc.gridy = 2;
        gbc.gridwidth = 1;
        gbc.weightx = 0.5;
        JButton saveButton = new JButton("설정 저장");
        saveButton.addActionListener(e -> saveSettings());
        panel.add(saveButton, gbc);

        gbc.gridx = 1;
        gbc.gridy = 2;
        gbc.gridwidth = 1;
        gbc.weightx = 0.5;
        JButton connectButton = new JButton("연결");
        connectButton.addActionListener(e -> serialComm.connect());
        panel.add(connectButton, gbc);

        // 전체 패널의 선호 크기 설정
        panel.setPreferredSize(new Dimension(100, 50));

        return panel;
    }


//    private JPanel createSettingsPanel() {
//        JPanel panel = new JPanel(new GridLayout(3, 2));
//
//        panel.add(new JLabel("Port:"));
//        portComboBox = new JComboBox<>(new String[]{"COM1", "COM2", "COM3", "COM4"});
//        portComboBox.setSelectedItem(settingsManager.getPort());
//        panel.add(portComboBox);
//
//        panel.add(new JLabel("Baud Rate:"));
//        rateComboBox = new JComboBox<>(new String[]{"9600", "115200"});
//        rateComboBox.setSelectedItem(String.valueOf(settingsManager.getRate()));
//        panel.add(rateComboBox);
//
//        JButton saveButton = new JButton("Save Settings");
//        saveButton.addActionListener(e -> saveSettings());
//        panel.add(saveButton);
//
//        JButton connectButton = new JButton("Connect");
//        connectButton.addActionListener(e -> serialComm.connect());
//        panel.add(connectButton);
//
//        return panel;
//    }

    private void showProductDialog(String productName) {
        JDialog dialog = new JDialog(this, "Select Quantity", true);
        dialog.setLayout(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10); // 여백 설정

        Product product = inventory.getProduct(productName);
        if (product == null) {
            JOptionPane.showMessageDialog(this, "Product not found!");
            return;
        }

        // 제품 이름 레이블
        JLabel productLabel = new JLabel(productName);
        productLabel.setFont(new Font("Arial", Font.BOLD, 16)); // 폰트 크기 및 스타일 조정
        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.gridwidth = 2; // 두 열을 차지하게 설정
        dialog.add(productLabel, gbc);

        // 개수 조절 레이블
        JLabel quantityLabel = new JLabel("Quantity:");
        quantityLabel.setFont(new Font("Arial", Font.PLAIN, 14)); // 폰트 크기 조정
        gbc.gridx = 0;
        gbc.gridy = 1;
        gbc.gridwidth = 1; // 한 열만 차지하게 설정
        dialog.add(quantityLabel, gbc);

        // 개수 조절 스피너
        SpinnerNumberModel spinnerModel = new SpinnerNumberModel(1, 1, 300, 1);
        JSpinner quantitySpinner = new JSpinner(spinnerModel);

        // JSpinner의 기본 에디터 크기 조정
        JSpinner.DefaultEditor editor = (JSpinner.DefaultEditor) quantitySpinner.getEditor();
        editor.getTextField().setFont(new Font("Arial", Font.PLAIN, 20)); // 폰트 크기 조정
        editor.getTextField().setPreferredSize(new Dimension(120, 40)); // 스피너 텍스트 필드 크기 조정
        quantitySpinner.setPreferredSize(new Dimension(200, 60)); // 스피너 전체 크기 조정

        gbc.gridx = 1;
        gbc.gridy = 1;
        dialog.add(quantitySpinner, gbc);

        // 추가 버튼
        JButton addButton = new JButton("Add to Sale");
        addButton.setPreferredSize(new Dimension(150, 40)); // 버튼 크기 조정
        addButton.setFont(new Font("Arial", Font.PLAIN, 14)); // 폰트 크기 조정
        addButton.addActionListener(e -> {
            int quantity = (Integer) quantitySpinner.getValue();
            if (product.getQuantity() >= quantity) {
                currentSale.addItem(product, quantity);
                inventory.updateQuantity(productName, quantity);
                updateSaleTable();
                dialog.dispose();
            } else {
                JOptionPane.showMessageDialog(this, "Insufficient stock!");
            }
        });

        gbc.gridx = 0;
        gbc.gridy = 2;
        gbc.gridwidth = 2; // 두 열을 차지하게 설정
        dialog.add(addButton, gbc);

        // 다이얼로그 크기 및 위치 설정
        dialog.setSize(400, 200); // 원하는 크기로 설정
        dialog.setLocationRelativeTo(this);
        dialog.setVisible(true);
    }



//    private void showProductDialog(String productName) {
//        JDialog dialog = new JDialog(this, "Select Quantity", true);
//        dialog.setLayout(new FlowLayout());
//
//        Product product = inventory.getProduct(productName);
//        if (product == null) {
//            JOptionPane.showMessageDialog(this, "Product not found!");
//            return;
//        }
//
//        JLabel productLabel = new JLabel(productName);
//        SpinnerNumberModel spinnerModel = new SpinnerNumberModel(1, 1, 100, 1);
//        JSpinner quantitySpinner = new JSpinner(spinnerModel);
//
//        JButton addButton = new JButton("Add to Sale");
//        addButton.addActionListener(e -> {
//            int quantity = (Integer) quantitySpinner.getValue();
//            if (product.getQuantity() >= quantity) {
//                currentSale.addItem(product, quantity);
//                inventory.updateQuantity(productName, quantity);
//                updateSaleTable();
//                dialog.dispose();
//            } else {
//                JOptionPane.showMessageDialog(this, "Insufficient stock!");
//            }
//        });
//
//        dialog.add(productLabel);
//        dialog.add(new JLabel("Quantity:"));
//        dialog.add(quantitySpinner);
//        dialog.add(addButton);
//
//        dialog.pack();
//        dialog.setLocationRelativeTo(this);
//        dialog.setVisible(true);
//    }

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
        byte[] receiptData = receipt.getBytes();
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
