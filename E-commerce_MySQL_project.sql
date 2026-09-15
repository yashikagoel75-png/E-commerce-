-- ============================================================================
-- COMPLETE E-COMMERCE DATABASE SYSTEM (MySQL)
-- Features: User roles, Product Catalog, Inventory, Cart, Orders, 
-- Payments, Reviews, Analytics Views, Stored Procedures, and Triggers.
-- ============================================================================

-- 1. DATABASE CREATION AND INITIALIZATION
DROP DATABASE IF EXISTS ECommerceDB;
CREATE DATABASE ECommerceDB;
USE ECommerceDB;

-- ============================================================================
-- 2. SCHEMA DEFINITION (TABLES)
-- ============================================================================

-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('customer', 'admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Addresses
CREATE TABLE Addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'USA',
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Product Categories
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Shopping Cart Table
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Cart Items Table
CREATE TABLE CartItems (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE (cart_id, product_id)
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (shipping_address_id) REFERENCES Addresses(address_id)
);

-- Order Items Table
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer', 'Debit Card') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100) UNIQUE,
    paid_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- Product Reviews Table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE (product_id, user_id)
);

-- ============================================================================
-- 3. AUTOMATION LOGIC (TRIGGERS & PROCEDURES)
-- ============================================================================

-- Trigger: Automatically deduct inventory stock when an item is ordered
DELIMITER //
CREATE TRIGGER After_OrderItem_Insert
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Stored Procedure: Checkout Cart (Converts Cart into Order)
DELIMITER //
CREATE PROCEDURE ProcessCheckout(
    IN p_user_id INT,
    IN p_address_id INT,
    IN p_payment_method VARCHAR(30)
)
BEGIN
    DECLARE v_cart_id INT;
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(10, 2) DEFAULT 0.00;

    -- Get User Cart
    SELECT cart_id INTO v_cart_id FROM Cart WHERE user_id = p_user_id;

    IF v_cart_id IS NOT NULL THEN
        -- Create New Order
        INSERT INTO Orders (user_id, shipping_address_id, total_amount) 
        VALUES (p_user_id, p_address_id, 0.00);
        
        SET v_order_id = LAST_INSERT_ID();

        -- Transfer Cart Items to Order Items
        INSERT INTO OrderItems (order_id, product_id, quantity, unit_price)
        SELECT v_order_id, ci.product_id, ci.quantity, p.price
        FROM CartItems ci
        JOIN Products p ON ci.product_id = p.product_id
        WHERE ci.cart_id = v_cart_id;

        -- Calculate and Update Total Amount
        SELECT SUM(quantity * unit_price) INTO v_total 
        FROM OrderItems WHERE order_id = v_order_id;

        UPDATE Orders SET total_amount = v_total WHERE order_id = v_order_id;

        -- Record Initial Payment Entry
        INSERT INTO Payments (order_id, payment_method, payment_status, transaction_id, paid_at)
        VALUES (v_order_id, p_payment_method, 'Completed', CONCAT('TXN-', UUID_SHORT()), NOW());

        -- Clear User Cart
        DELETE FROM CartItems WHERE cart_id = v_cart_id;
        
        SELECT v_order_id AS created_order_id, 'Checkout Successful' AS message;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Active cart not found for user.';
    END IF;
END //
DELIMITER ;

-- ============================================================================
-- 4. SAMPLE DATA POPULATION
-- ============================================================================

INSERT INTO Categories (category_name, description) VALUES
('Electronics', 'Gadgets, devices, and electronic accessories'),
('Books', 'Printed books, novels, and educational reading material'),
('Clothing', 'Apparel and wearables');

INSERT INTO Products (category_id, product_name, description, price, stock_quantity) VALUES
(1, 'Wireless Bluetooth Headphones', 'Noise canceling over-ear headphones', 99.99, 100),
(1, 'Smartphone Stand', 'Adjustable aluminum phone desk holder', 15.49, 200),
(2, 'The Psychology of Money', 'Timeless lessons on wealth, greed, and happiness', 18.00, 50),
(2, 'Rich Dad Poor Dad', 'Personal finance classic by Robert Kiyosaki', 16.50, 40),
(3, 'Classic Cotton T-Shirt', '100% Cotton unisex basic t-shirt', 12.99, 150);

INSERT INTO Users (first_name, last_name, email, password_hash, phone, role) VALUES
('John', 'Doe', 'john.doe@example.com', 'hashed_pass_123', '555-1000', 'customer'),
('Jane', 'Smith', 'jane.smith@example.com', 'hashed_pass_456', '555-2000', 'customer'),
('Admin', 'User', 'admin@store.com', 'admin_secure_hash', '555-0000', 'admin');

INSERT INTO Addresses (user_id, street_address, city, state, postal_code, country, is_default) VALUES
(1, '123 Main St', 'New York', 'NY', '10001', 'USA', TRUE),
(2, '456 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA', TRUE);

-- Create Carts and Add Items
INSERT INTO Cart (user_id) VALUES (1), (2);

INSERT INTO CartItems (cart_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 3, 2),
(2, 4, 1);

-- Run Checkout for User 1 using Stored Procedure
CALL ProcessCheckout(1, 1, 'Credit Card');

-- Add Product Reviews
INSERT INTO Reviews (product_id, user_id, rating, comment) VALUES
(1, 1, 5, 'Great sound quality and long battery life!'),
(3, 1, 4, 'Very insightful book on managing personal finances.');

-- ============================================================================
-- 5. BUSINESS INSIGHTS & ANALYTICS VIEWS
-- ============================================================================

-- Insight 1: Best-Selling Products by Revenue
CREATE VIEW View_TopSellingProducts AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue_generated
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_revenue_generated DESC;

-- Insight 2: Customer Purchase Summary & Lifetime Value (LTV)
CREATE VIEW View_CustomerLifetimeValue AS
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    u.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    IFNULL(SUM(o.total_amount), 0.00) AS total_spent
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id
WHERE u.role = 'customer'
GROUP BY u.user_id, customer_name, u.email
ORDER BY total_spent DESC;

-- Insight 3: Low Inventory Alert System (Products with Stock < 45)
CREATE VIEW View_LowStockAlert AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.stock_quantity,
    p.price
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
WHERE p.stock_quantity < 45
ORDER BY p.stock_quantity ASC;

-- Insight 4: Product Average Ratings Breakdown
CREATE VIEW View_ProductRatings AS
SELECT 
    p.product_id,
    p.product_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM Products p
LEFT JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name;

-- ============================================================================
-- 6. ANALYTICS QUERY EXECUTION EXAMPLES
-- ============================================================================

-- Run Insights Queries
SELECT * FROM View_TopSellingProducts;
SELECT * FROM View_CustomerLifetimeValue;
SELECT * FROM View_LowStockAlert;
SELECT * FROM View_ProductRatings;