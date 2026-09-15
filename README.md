# E-Commerce Database System (MySQL)

A production-ready MySQL relational database schema designed for modern e-commerce applications. It includes user authentication structures, a product catalog, inventory management, shopping carts, order workflows, automated triggers, checkout stored procedures, and business intelligence analytics views.

---

## Features

* **User Management & RBAC**: Supports customer and admin roles, multiple shipping addresses per user, and default address flags.
* **Product Catalog & Inventory**: Hierarchical category mapping with built-in stock level constraints and check guards.
* **Cart & Checkout Engine**: Persistent shopping cart structure that transitions smoothly into finalized orders via ACID-compliant stored procedures.
* **Automated Stock Deduction**: MySQL triggers that dynamically decrease product stock upon order item creation.
* **Integrated Payments & Reviews**: Handles order payment states (`Pending`, `Completed`, `Failed`, `Refunded`) and user product reviews (1–5 scale).
* **Analytics Views**: Pre-configured views for Customer Lifetime Value (LTV), revenue per product, product rating averages, and real-time low-inventory alerts.

---

## Schema Architecture

```
                  +-------------------+
                  |       Users       |
                  +-------------------+
                    /               \
                   /                 \
        +------------+             +---------------+
        | Addresses  |             |     Cart      |
        +------------+             +---------------+
               |                           |
               |                           |
        +------------+             +---------------+
        |   Orders   |             |   CartItems   |
        +------------+             +---------------+
          /        \                       |
         /          \                      |
+------------+    +------------+    +---------------+
|  Payments  |    | OrderItems |----|   Products    |
+------------+    +------------+    +---------------+
                                      /          \
                                     /            \
                           +------------+   +---------------+
                           | Categories |   |    Reviews    |
                           +------------+   +---------------+
```

---

## Database Relational Map

| Table | Description | Key Relationships |
| :--- | :--- | :--- |
| `Users` | User profiles and role assignments (`customer`, `admin`). | Parent to `Addresses`, `Cart`, `Orders`, `Reviews`. |
| `Addresses` | Shipping and billing addresses per user. | Foreign Key -> `Users(user_id)` |
| `Categories` | Classification lookup for inventory items. | Parent to `Products`. |
| `Products` | Catalog items, unit prices, and active stock levels. | Foreign Key -> `Categories(category_id)` |
| `Cart` | Active persistent cart assigned per user. | Foreign Key -> `Users(user_id)` |
| `CartItems` | Line items stored inside a user's active cart. | Foreign Keys -> `Cart(cart_id)`, `Products(product_id)` |
| `Orders` | Finalized customer orders and tracking status. | Foreign Keys -> `Users(user_id)`, `Addresses(address_id)` |
| `OrderItems` | Snapshot of items, quantities, and prices per order. | Foreign Keys -> `Orders(order_id)`, `Products(product_id)` |
| `Payments` | Payment transactions linked directly to orders. | Foreign Key -> `Orders(order_id)` |
| `Reviews` | Product ratings and reviews submitted by customers. | Foreign Keys -> `Products(product_id)`, `Users(user_id)` |

---

## Getting Started

### Prerequisites
* **MySQL Server**: Version 8.0 or higher
* **MySQL Client**: MySQL Workbench, DBeaver, or MySQL CLI

### Installation & Execution

1. Save your SQL schema script as `ECommerceDB.sql`.
2. Run the SQL script in your MySQL environment:

   **Using MySQL CLI:**
   ```bash
   mysql -u root -p < ECommerceDB.sql
   ```

   **Using MySQL Workbench / DBeaver:**
   * Open the client and connect to your server.
   * Open `ECommerceDB.sql`.
   * Execute the full script.

---

## Automation & Business Logic

### Triggers

* **`After_OrderItem_Insert`**: Executes after a record is inserted into `OrderItems`. Automatically subtracts the ordered quantity from the corresponding product's `stock_quantity` in the `Products` table.

### Stored Procedures

* **`ProcessCheckout(p_user_id, p_address_id, p_payment_method)`**:
  1. Identifies the user's active cart.
  2. Generates a new `Orders` record.
  3. Copies all items from `CartItems` into `OrderItems` (preserving unit prices at time of purchase).
  4. Calculates the total order amount and updates the order record.
  5. Triggers stock deduction via `After_OrderItem_Insert`.
  6. Creates a `Payments` record with a generated transaction ID (`TXN-...`).
  7. Clears the user's `CartItems`.

---

## Business Insights & Analytics Views

### 1. Best-Selling Products by Revenue
```sql
SELECT * FROM View_TopSellingProducts;
```
*Aggregates order items to show total volume sold and total revenue generated per product.*

### 2. Customer Lifetime Value (LTV)
```sql
SELECT * FROM View_CustomerLifetimeValue;
```
*Lists all customers sorted by their cumulative spending history.*

### 3. Low Stock Alert System
```sql
SELECT * FROM View_LowStockAlert;
```
*Filters products where stock levels drop below 45 units for proactive inventory replenishment.*

### 4. Product Average Ratings
```sql
SELECT * FROM View_ProductRatings;
```
*Generates review counts and average ratings rounded to 2 decimal places per product.*

---

## Verification & Testing Queries

To verify execution and inspect state after running the sample script:

```sql
USE ECommerceDB;

-- Check inventory levels after automated checkout
SELECT product_id, product_name, stock_quantity FROM Products;

-- Inspect processed order details
SELECT * FROM Orders;
SELECT * FROM OrderItems;

-- Verify payment record generated by stored procedure
SELECT * FROM Payments;
```
