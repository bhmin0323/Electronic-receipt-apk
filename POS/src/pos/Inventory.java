package pos;

import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

public class Inventory {
    private Map<String, Product> products;

    public Inventory() {
        products = new HashMap<>();
        // 샘플 상품 추가
        addProduct(new Product("사과", 1000, 999));
        addProduct(new Product("바나나", 2000, 999));
        addProduct(new Product("오렌지", 3000, 999));
        addProduct(new Product("딸기", 4000, 999));
        addProduct(new Product("포도", 5000, 999));
        addProduct(new Product("수박", 6000, 999));
        addProduct(new Product("참외", 7000, 999));
        addProduct(new Product("메론", 8000, 999));
        addProduct(new Product("당근", 9000, 999));
    }

    public void addProduct(Product product) {
        products.put(product.getName(), product);
    }

    public Product getProduct(String name) {
        return products.get(name);
    }

    public void updateQuantity(String name, int quantity) {
        Product product = products.get(name);
        if (product != null) {
            product.setQuantity(product.getQuantity() - quantity);
        }
    }

    public String[] getProductNames() {
        return products.keySet().toArray(new String[0]);
    }
}