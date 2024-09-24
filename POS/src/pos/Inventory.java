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
        addProduct(new Product("사과", 1.0, 999));
        addProduct(new Product("바나나", 0.5, 999));
        addProduct(new Product("오렌지", 0.75, 999));
        addProduct(new Product("a", 11.0, 999));
        addProduct(new Product("b", 0.35, 999));
        addProduct(new Product("c", 0.7, 999));
        addProduct(new Product("d", 1.5, 999));
        addProduct(new Product("e", 2.5, 999));
        addProduct(new Product("f", 1.75, 999));
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