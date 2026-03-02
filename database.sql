-- ============================================
-- কৃষি মিত্র - ডেটাবেস স্কিমা
-- ============================================

CREATE DATABASE IF NOT EXISTS krishi_mitra CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE krishi_mitra;

-- Admin Table
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Farmers (Krishok) Table
CREATE TABLE farmers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    district VARCHAR(100),
    upazila VARCHAR(100),
    nid_number VARCHAR(20),
    bank_account VARCHAR(50),
    bkash_number VARCHAR(20),
    profile_image VARCHAR(255),
    is_verified TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buyers Table
CREATE TABLE buyers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    district VARCHAR(100),
    upazila VARCHAR(100),
    profile_image VARCHAR(255),
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name_bn VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    icon VARCHAR(10),
    description TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL,
    category_id INT NOT NULL,
    name_bn VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    description TEXT,
    our_price DECIMAL(10,2) NOT NULL,
    market_price DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) DEFAULT 'কেজি',
    minimum_order DECIMAL(10,2) DEFAULT 1,
    available_quantity DECIMAL(10,2) NOT NULL,
    image1 VARCHAR(255),
    image2 VARCHAR(255),
    image3 VARCHAR(255),
    is_organic TINYINT(1) DEFAULT 0,
    is_seasonal TINYINT(1) DEFAULT 0,
    season VARCHAR(50),
    harvest_date DATE,
    is_approved TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Orders Table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    buyer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_charge DECIMAL(10,2) DEFAULT 80.00,
    grand_total DECIMAL(10,2) NOT NULL,
    payment_method ENUM('bkash','nagad','nid','cod','bank') NOT NULL,
    payment_number VARCHAR(50),
    payment_transaction_id VARCHAR(100),
    payment_status ENUM('pending','paid','failed') DEFAULT 'pending',
    delivery_address TEXT NOT NULL,
    delivery_district VARCHAR(100),
    delivery_upazila VARCHAR(100),
    order_status ENUM('pending','confirmed','processing','shipped','delivered','cancelled') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES buyers(id)
);

-- Order Items Table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    farmer_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (farmer_id) REFERENCES farmers(id)
);

-- Reviews Table
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    buyer_id INT NOT NULL,
    order_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (buyer_id) REFERENCES buyers(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- Delivery Charges Table
CREATE TABLE delivery_charges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    district VARCHAR(100) NOT NULL,
    charge DECIMAL(10,2) NOT NULL DEFAULT 80.00,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Settings Table
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- SEED DATA
-- ============================================

-- Default Admin
INSERT INTO admins (name, email, password, phone) VALUES
('Admin', 'admin@krishimitra.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '01700000000');
-- Password: password

-- Categories
INSERT INTO categories (name_bn, name_en, icon) VALUES
('শুকনো ফল', 'Dry Fruits', '🥜'),
('গ্রামীণ পণ্য', 'Rural Products', '🌾'),
('মৌসুমী ফল', 'Seasonal Fruits', '🍎'),
('শস্য ও দানা', 'Cereals & Grains', '🌽'),
('মশলা', 'Spices', '🌶️'),
('সবজি', 'Vegetables', '🥦');

-- Settings
INSERT INTO settings (setting_key, setting_value) VALUES
('site_name', 'কৃষি মিত্র'),
('default_delivery_charge', '80'),
('bkash_number', '01XXXXXXXXX'),
('nagad_number', '01XXXXXXXXX'),
('bank_name', 'ডাচ বাংলা ব্যাংক'),
('bank_account', '1234567890'),
('bank_routing', '090261XXX');

-- Delivery charges by district
INSERT INTO delivery_charges (district, charge) VALUES
('ঢাকা', 60), ('চট্টগ্রাম', 100), ('সিলেট', 120),
('রাজশাহী', 100), ('খুলনা', 100), ('বরিশাল', 100),
('ময়মনসিংহ', 80), ('রংপুর', 120), ('কুমিল্লা', 80),
('নারায়ণগঞ্জ', 70), ('গাজীপুর', 70);