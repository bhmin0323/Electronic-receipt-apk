package pos;

import SerialSet.*;
import com.fazecast.jSerialComm.SerialPort;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.io.UnsupportedEncodingException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Base64;
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
    private JLabel connectionStatusLabel;

    public POSUI(SettingsManager settingsManager, SerialCommunication serialComm, Inventory inventory) {
        this.settingsManager = settingsManager;
        this.serialComm = serialComm;
        this.inventory = inventory;
        this.currentSale = new Sale();

        setTitle("POS System");
        setSize(1500, 750);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.addTab("상품", createSalesPanel());
        tabbedPane.addTab("설정", createSettingsPanel());

        add(tabbedPane);

        SwingUtilities.invokeLater(() -> {
            if (!serialComm.connect()) {
                JOptionPane.showMessageDialog(this, "연결할 수 없습니다.", "연결 실패", JOptionPane.WARNING_MESSAGE);
            }
            updateConnectionStatus();
        });

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



            // 버튼을 클릭하면 수량 증가 및 테이블에 반영
            productButton.addActionListener(e ->showProductDialog(productName) );

            productListPanel.add(productButton); // 상품 목록 패널에 버튼 추가
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
        saleTable = new JTable(new DefaultTableModel(new Object[]{"상품", "가격", "수량", "합계"}, 0));
        JScrollPane saleScrollPane = new JScrollPane(saleTable);

        // 스플릿 패널
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, productScrollPane, saleScrollPane);
        splitPane.setResizeWeight(0.9); // 제품 목록 30%, 판매 테이블 70%
        splitPane.setDividerLocation(1100); // 초기 분할 위치 (조정 가능)

        // 총 합계 레이블 및 계산서 출력 버튼
        totalLabel = new JLabel("총 합계: 0원");
        totalLabel.setFont(new Font("맑은 고딕", Font.BOLD, 24)); // 폰트 크기 키우기

        JButton completeButton = new JButton("계산서 출력");
        completeButton.setPreferredSize(new Dimension(200, 50)); // 버튼 크기 설정
        completeButton.setFont(new Font("맑은 고딕", Font.PLAIN, 16)); // 버튼 폰트 크기 설정
        completeButton.addActionListener(e -> completeSale());

        // 하단 패널 설정: 우측 정렬로 배치
        JPanel bottomPanel = new JPanel(new BorderLayout());
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT)); // 버튼을 우측 정렬

        buttonPanel.add(totalLabel);
        buttonPanel.add(completeButton);

        bottomPanel.add(buttonPanel, BorderLayout.EAST); // 우측 정렬로 배치

        panel.add(splitPane, BorderLayout.CENTER);
        panel.add(bottomPanel, BorderLayout.SOUTH); // 하단에 배치

        return panel;
    }



    private JPanel createSettingsPanel() {
        JPanel panel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();

        gbc.insets = new Insets(5, 5, 5, 5); // 여백 설정 조정

        // 포트 라벨과 콤보박스
        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.weightx = 0.3;
        JLabel portLabel = new JLabel("포트:");
        panel.add(portLabel, gbc);

        gbc.gridx = 1;
        gbc.gridy = 0;
        gbc.weightx = 0.7;
        portComboBox = new JComboBox<>(new String[]{"COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9"});
        portComboBox.setSelectedItem(settingsManager.getPort());
        portComboBox.setPreferredSize(new Dimension(100, 25));
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
        rateComboBox.setPreferredSize(new Dimension(100, 25));
        panel.add(rateComboBox, gbc);

        // 설정 저장 버튼
        gbc.gridx = 0;
        gbc.gridy = 2;
        gbc.gridwidth = 2;
        gbc.weightx = 1.0;
        gbc.anchor = GridBagConstraints.CENTER;
        JButton saveButton = new JButton("설정 적용");
        saveButton.addActionListener(e -> saveSettings());
        panel.add(saveButton, gbc);

        // 연결 상태 표시 레이블
        gbc.gridx = 0;
        gbc.gridy = 3;
        gbc.gridwidth = 2;
        connectionStatusLabel = new JLabel("연결 상태: 확인 중...");
        panel.add(connectionStatusLabel, gbc);

        // 연결 버튼과 연결 해제 버튼을 포함할 패널
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 0)); // 간격을 10으로 조정
        JButton connectButton = new JButton("연결");
        connectButton.addActionListener(e -> {
            if (serialComm.connect()) {
                JOptionPane.showMessageDialog(this, "연결되었습니다.");
            } else if(serialComm.isConnected()) {
                JOptionPane.showMessageDialog(this, "이미 연결되어있습니다.");
            } else {
                JOptionPane.showMessageDialog(this, "연결에 실패했습니다.", "연결 실패", JOptionPane.WARNING_MESSAGE);
            }
            updateConnectionStatus();
        });
        JButton disconnectButton = new JButton("연결 해제");
        disconnectButton.addActionListener(e -> {
            serialComm.disconnect();
            updateConnectionStatus();
            JOptionPane.showMessageDialog(this, "연결이 해제되었습니다.");
        });
        buttonPanel.add(connectButton);
        buttonPanel.add(disconnectButton);

        gbc.gridx = 0;
        gbc.gridy = 4;
        gbc.gridwidth = 2;
        panel.add(buttonPanel, gbc);

        return panel;
    }

    private void updateConnectionStatus() {
        boolean isConnected = serialComm.isConnected();
        connectionStatusLabel.setText("연결 상태: " + (isConnected ? "연결됨" : "연결 안됨"));
    }



    private void showProductDialog(String productName) {
        // 각 상품에 대한 초기 수량을 설정하는 배열
        final int[] quantity = {1};
        Product product = inventory.getProduct(productName); // 해당 상품 객체 가져오기
        double price = product.getPrice(); // 상품 가격
        DefaultTableModel model = (DefaultTableModel) saleTable.getModel();

        // 테이블에서 이미 해당 상품이 있는지 확인
        boolean productExists = false;
        for (int i = 0; i < model.getRowCount(); i++) {
            if (model.getValueAt(i, 0).equals(productName)) {
                // 해당 상품이 있으면 수량을 증가시키고 소계를 업데이트
                int currentQuantity = (int) model.getValueAt(i, 2);
                currentQuantity++;
                double subtotal = price * currentQuantity;
                model.setValueAt(currentQuantity, i, 2); // 수량 업데이트
                model.setValueAt(String.format("₩%.0f", subtotal), i, 3); // 소계 업데이트
                productExists = true;
                currentSale.addItem(product, 1);
                inventory.updateQuantity(productName, 1);
                updateSaleTable();
                break;
            }
        }

        // 해당 상품이 테이블에 없으면 새 행 추가
        if (!productExists) {
            double subtotal = price * quantity[0]; // 소계 계산
            model.addRow(new Object[]{product.getName(), price, quantity[0], String.format("₩%.0f", subtotal)});
            quantity[0]++; // 수량 증가
            currentSale.addItem(product, 1);
            inventory.updateQuantity(productName, 1);
            updateSaleTable();
        }

    }


//    private void showProductDialog(String productName) {
//        JDialog dialog = new JDialog(this, "수량 선택", true);
//        dialog.setLayout(new GridBagLayout());
//        GridBagConstraints gbc = new GridBagConstraints();
//        gbc.insets = new Insets(10, 10, 10, 10); // 여백 설정
//
//        Product product = inventory.getProduct(productName);
//
//
//        // 제품 이름 레이블
//        JLabel productLabel = new JLabel(productName);
//        productLabel.setFont(new Font("맑은 고딕", Font.BOLD, 16)); // 폰트 크기 및 스타일 조정
//        gbc.gridx = 0;
//        gbc.gridy = 0;
//        gbc.gridwidth = 2; // 두 열을 차지하게 설정
//        dialog.add(productLabel, gbc);
//
//        // 개수 조절 레이블
//        JLabel quantityLabel = new JLabel("수량:");
//        quantityLabel.setFont(new Font("맑은 고딕", Font.PLAIN, 14)); // 폰트 크기 조정
//        gbc.gridx = 0;
//        gbc.gridy = 1;
//        gbc.gridwidth = 1; // 한 열만 차지하게 설정
//        dialog.add(quantityLabel, gbc);
//
//        // 개수 조절 스피너
//        SpinnerNumberModel spinnerModel = new SpinnerNumberModel(1, 1, 300, 1);
//        JSpinner quantitySpinner = new JSpinner(spinnerModel);
//
//        // JSpinner의 기본 에디터 크기 조정
//        JSpinner.DefaultEditor editor = (JSpinner.DefaultEditor) quantitySpinner.getEditor();
//        editor.getTextField().setFont(new Font("Arial", Font.PLAIN, 20)); // 폰트 크기 조정
//        editor.getTextField().setPreferredSize(new Dimension(120, 40)); // 스피너 텍스트 필드 크기 조정
//        quantitySpinner.setPreferredSize(new Dimension(200, 60)); // 스피너 전체 크기 조정
//
//        gbc.gridx = 1;
//        gbc.gridy = 1;
//        dialog.add(quantitySpinner, gbc);
//
//        // 추가 버튼
//        JButton addButton = new JButton("상품 추가");
//        addButton.setPreferredSize(new Dimension(150, 40)); // 버튼 크기 조정
//        addButton.setFont(new Font("맑은 고딕", Font.PLAIN, 14)); // 폰트 크기 조정
//        addButton.addActionListener(e -> {
//            int quantity = (Integer) quantitySpinner.getValue();
//            if (product.getQuantity() >= quantity) {
//                currentSale.addItem(product, quantity);
//                inventory.updateQuantity(productName, quantity);
//                updateSaleTable();
//                dialog.dispose();
//            } else {
//                JOptionPane.showMessageDialog(this, "수량이 너무 많습니다.");
//            }
//        });
//
//        gbc.gridx = 0;
//        gbc.gridy = 2;
//        gbc.gridwidth = 2; // 두 열을 차지하게 설정
//        dialog.add(addButton, gbc);
//
//        // 다이얼로그 크기 및 위치 설정
//        dialog.setSize(400, 200); // 원하는 크기로 설정
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
            model.addRow(new Object[]{product.getName(), String.format("₩%.0f", product.getPrice()), quantity, String.format("₩%.0f", subtotal)});
        }

        totalLabel.setText(String.format("총 합계: %.0f원", currentSale.getTotal()));
    }

private void completeSale() {
    if (currentSale.getItems().isEmpty()) {
        JOptionPane.showMessageDialog(this, "저장된 목록이 없습니다.");
        return;
    }

    serialComm.clearBuffer();
    String receipt = generateReceipt();
    byte[] receiptData;
    byte[] cutCommand = {0x1d, 'V', 1};

    try {
        receiptData = receipt.getBytes("CP949");
    } catch (UnsupportedEncodingException e) {
        System.err.println("CP949 encoding not supported: " + e.getMessage());
        receiptData = receipt.getBytes(); // 기본 인코딩 사용
    }

    byte[] finalData = new byte[receiptData.length + cutCommand.length];

    System.arraycopy(receiptData, 0, finalData, 0, receiptData.length);
    System.arraycopy(cutCommand, 0, finalData, receiptData.length, cutCommand.length);

//    // Base64로 인코딩
//    String base64EncodedData = Base64.getEncoder().encodeToString(finalData);

    serialComm.sendData(finalData);

    JOptionPane.showMessageDialog(this, "완료되었습니다");

    currentSale = new Sale();
    updateSaleTable();
}
    // 한글과 숫자의 표시 너비를 계산하는 메서드
    public int getDisplayLength(String str) {
        int length = 0;
        for (char c : str.toCharArray()) {
            if (Character.isDigit(c)) {
                length += 1; // 숫자는 1칸
            } else {
                length += 2; // 한글은 2칸
            }
        }
        return length;
    }

    // 고정된 너비로 문자열을 맞추는 메서드
    public String padRight(String str, int totalWidth) {
        int length = getDisplayLength(str);
        int padding = totalWidth - length;

        StringBuilder paddedStr = new StringBuilder(str);
        for (int i = 0; i < padding; i++) {
            paddedStr.append(' '); // 필요한 만큼 공백 추가
        }
        return paddedStr.toString();
    }

    private String generateReceipt() {
        StringBuilder receipt = new StringBuilder();
        double total = currentSale.getTotal();
        double subtotal = total / 1.1;
        double taxAmount = subtotal * 0.1;

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String formattedDateTime = now.format(formatter);


        receipt.append("상호: 상도동주민들\n");
        receipt.append("사업자번호: 123-45-67890  TEL: 02-820-0114\n");
        receipt.append("대표자: 이지민\n");
        receipt.append("주소: 서울특별시 동작구 상도로 369\n");
        receipt.append("------------------------------------------\n");
        receipt.append("상품명           단가      수량      금액 \n");
        receipt.append("------------------------------------------\n");

        // 각 상품의 정보 추가
        for (Map.Entry<Product, Integer> entry : currentSale.getItems().entrySet()) {
            Product product = entry.getKey();
            int quantity = entry.getValue();
            double itemTotal = product.getPrice() * quantity;


            String paddedName = padRight(product.getName(), 15);
            String price = String.format("%,6d", Math.round(product.getPrice()));
            String qty = String.format("%4d", quantity);
            String totalPrice = String.format("%,8d", Math.round(itemTotal));

            // 상품 정보 추가
            receipt.append(String.format("%s %s원 %s개 %s원\n",
                    paddedName, price, qty, totalPrice
            ));
        }

        receipt.append("------------------------------------------\n");
        receipt.append(String.format("과세물품:%31s원\n", String.format("%,d", Math.round(subtotal))));
        receipt.append(String.format("부 가 세:%31s원\n", String.format("%,d", Math.round(taxAmount))));
        receipt.append(String.format("총 합 계:%31s원\n", String.format("%,d", Math.round(total))));
        receipt.append("------------------------------------------\n");
        receipt.append("거래일시: ").append(formattedDateTime).append("\n");
        receipt.append("------------------------------------------\n");
        receipt.append("                              전자서명전표\n\n");
        receipt.append("찾아주셔서 감사합니다. (고객용)\n");
        receipt.append("\n");
        receipt.append("\n");
        receipt.append("\n");
        receipt.append("\n");
        receipt.append("\n");
        receipt.append("\n");


        return receipt.toString();
    }

    private void saveSettings() {
        String selectedPort = (String) portComboBox.getSelectedItem();
        int selectedRate = Integer.parseInt((String) rateComboBox.getSelectedItem());

        settingsManager.setPort(selectedPort);
        settingsManager.setRate(selectedRate);

        JOptionPane.showMessageDialog(this, "설정이 저장되었습니다.");
    }


}
