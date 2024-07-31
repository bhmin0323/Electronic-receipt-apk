package pos;

import java.util.HashMap;
import java.util.Map;

public class Sale {
    private Map<Product, Integer> items;
    private double total;

    public Sale() {
        items = new HashMap<>();
        total = 0.0;
    }

    public void addItem(Product product, int quantity) {
        items.put(product, items.getOrDefault(product, 0) + quantity);
        total += product.getPrice() * quantity;
    }

    public Map<Product, Integer> getItems() { return items; }
    public double getTotal() { return total; }
}