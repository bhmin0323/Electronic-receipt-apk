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
        addProduct(new Product("Apple", 1.0, 100));
        addProduct(new Product("Banana", 0.5, 150));
        addProduct(new Product("Orange", 0.75, 120));
        addProduct(new Product("a", 11.0, 100));
        addProduct(new Product("b", 0.35, 150));
        addProduct(new Product("c", 0.7, 120));
        addProduct(new Product("d", 1.5, 100));
        addProduct(new Product("e", 2.5, 150));
        addProduct(new Product("f", 1.75, 120));
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