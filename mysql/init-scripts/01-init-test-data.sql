-- MySQL 测试数据初始化脚本
-- 创建经典的测试表结构和数据

USE test;

-- 1. 用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 商品分类表
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id INT DEFAULT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_parent_id (parent_id),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 商品表
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    stock_quantity INT DEFAULT 0,
    min_stock_level INT DEFAULT 0,
    weight DECIMAL(8,3),
    dimensions VARCHAR(50),
    status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_category_id (category_id),
    INDEX idx_sku (sku),
    INDEX idx_price (price),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. 订单表
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL,
    shipping_amount DECIMAL(8,2) DEFAULT 0.00,
    tax_amount DECIMAL(8,2) DEFAULT 0.00,
    discount_amount DECIMAL(8,2) DEFAULT 0.00,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash') DEFAULT 'credit_card',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. 订单详情表
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. 购物车表
CREATE TABLE IF NOT EXISTS shopping_cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product (user_id, product_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入测试数据

-- 插入用户数据
INSERT INTO users (username, email, password_hash, full_name, phone, status) VALUES
('admin', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '系统管理员', '13800138000', 'active'),
('john_doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '约翰·多伊', '13800138001', 'active'),
('jane_smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '简·史密斯', '13800138002', 'active'),
('bob_wilson', 'bob@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '鲍勃·威尔逊', '13800138003', 'inactive'),
('alice_brown', 'alice@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '爱丽丝·布朗', '13800138004', 'active');

-- 插入商品分类数据
INSERT INTO categories (name, description, parent_id, sort_order) VALUES
('电子产品', '各类电子设备和配件', NULL, 1),
('服装鞋帽', '男女服装、鞋子、帽子等', NULL, 2),
('家居用品', '家庭日用品和装饰用品', NULL, 3),
('图书音像', '书籍、音乐、电影等', NULL, 4),
('手机数码', '手机、平板、数码相机等', 1, 1),
('电脑办公', '笔记本、台式机、办公用品', 1, 2),
('男装', '男士服装', 2, 1),
('女装', '女士服装', 2, 2),
('厨房用品', '锅具、餐具、小家电', 3, 1),
('卧室用品', '床上用品、家具', 3, 2);

-- 插入商品数据
INSERT INTO products (name, description, sku, category_id, price, cost_price, stock_quantity, min_stock_level, weight, status, featured) VALUES
('iPhone 15 Pro', '苹果最新旗舰手机，256GB存储', 'IP15P-256', 5, 8999.00, 7200.00, 50, 10, 0.221, 'active', TRUE),
('MacBook Air M2', '13英寸苹果笔记本电脑', 'MBA-M2-13', 6, 9999.00, 8000.00, 30, 5, 1.240, 'active', TRUE),
('Nike Air Max 270', '耐克气垫跑鞋', 'NIKE-AM270', 2, 899.00, 450.00, 100, 20, 0.350, 'active', FALSE),
('Adidas Ultraboost 22', '阿迪达斯跑鞋', 'ADS-UB22', 2, 1299.00, 650.00, 80, 15, 0.320, 'active', TRUE),
('Samsung 4K电视 55寸', '三星智能电视', 'SAM-TV55', 1, 3999.00, 3200.00, 25, 5, 15.500, 'active', FALSE),
('戴森吸尘器 V15', '无线手持吸尘器', 'DYS-V15', 9, 4999.00, 4000.00, 40, 8, 2.200, 'active', TRUE),
('宜家沙发床', '多功能沙发床', 'IKEA-SB01', 10, 2999.00, 2000.00, 15, 3, 45.000, 'active', FALSE),
('小米空气净化器', '智能空气净化器', 'MI-AP01', 9, 899.00, 600.00, 60, 12, 4.800, 'active', FALSE),
('Levi\'s 501牛仔裤', '经典直筒牛仔裤', 'LEVI-501', 7, 599.00, 300.00, 120, 25, 0.600, 'active', FALSE),
('Zara女士连衣裙', '春季新款连衣裙', 'ZARA-DR01', 8, 299.00, 150.00, 80, 15, 0.300, 'active', TRUE);

-- 插入订单数据
INSERT INTO orders (order_number, user_id, status, total_amount, shipping_amount, tax_amount, payment_method, payment_status, shipping_address, billing_address, order_date) VALUES
('ORD-2024-001', 2, 'delivered', 9898.00, 0.00, 899.00, 'credit_card', 'paid', '北京市朝阳区建国路1号', '北京市朝阳区建国路1号', '2024-01-15 10:30:00'),
('ORD-2024-002', 3, 'shipped', 1299.00, 20.00, 119.00, 'paypal', 'paid', '上海市浦东新区陆家嘴路100号', '上海市浦东新区陆家嘴路100号', '2024-01-16 14:20:00'),
('ORD-2024-003', 2, 'processing', 4999.00, 50.00, 450.00, 'credit_card', 'paid', '广州市天河区珠江新城1号', '广州市天河区珠江新城1号', '2024-01-17 09:15:00'),
('ORD-2024-004', 5, 'pending', 898.00, 15.00, 81.00, 'bank_transfer', 'pending', '深圳市南山区科技园路1号', '深圳市南山区科技园路1号', '2024-01-18 16:45:00'),
('ORD-2024-005', 3, 'cancelled', 599.00, 10.00, 54.00, 'credit_card', 'refunded', '杭州市西湖区文三路1号', '杭州市西湖区文三路1号', '2024-01-19 11:30:00');

-- 插入订单详情数据
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 1, 8999.00, 8999.00),
(1, 8, 1, 899.00, 899.00),
(2, 4, 1, 1299.00, 1299.00),
(3, 6, 1, 4999.00, 4999.00),
(4, 8, 1, 899.00, 899.00),
(5, 9, 1, 599.00, 599.00);

-- 插入购物车数据
INSERT INTO shopping_cart (user_id, product_id, quantity) VALUES
(2, 2, 1),
(2, 5, 1),
(3, 7, 1),
(3, 10, 2),
(5, 1, 1),
(5, 3, 1);

-- 创建一些有用的视图

-- 订单统计视图
CREATE VIEW order_summary AS
SELECT 
    o.id,
    o.order_number,
    u.username,
    u.full_name,
    o.status,
    o.total_amount,
    o.order_date,
    COUNT(oi.id) as item_count
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, u.username, u.full_name, o.status, o.total_amount, o.order_date;

-- 商品库存预警视图
CREATE VIEW low_stock_products AS
SELECT 
    p.id,
    p.name,
    p.sku,
    c.name as category_name,
    p.stock_quantity,
    p.min_stock_level,
    (p.min_stock_level - p.stock_quantity) as shortage
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.stock_quantity <= p.min_stock_level
AND p.status = 'active';

-- 用户购买统计视图
CREATE VIEW user_purchase_stats AS
SELECT 
    u.id,
    u.username,
    u.full_name,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id AND o.status != 'cancelled'
GROUP BY u.id, u.username, u.full_name;

-- 创建存储过程示例

DELIMITER //

-- 获取用户购物车总金额的存储过程
CREATE PROCEDURE GetCartTotal(IN user_id INT, OUT total_amount DECIMAL(12,2))
BEGIN
    SELECT COALESCE(SUM(sc.quantity * p.price), 0)
    INTO total_amount
    FROM shopping_cart sc
    JOIN products p ON sc.product_id = p.id
    WHERE sc.user_id = user_id AND p.status = 'active';
END //

-- 更新商品库存的存储过程
CREATE PROCEDURE UpdateProductStock(IN product_id INT, IN quantity_change INT)
BEGIN
    DECLARE current_stock INT;
    
    SELECT stock_quantity INTO current_stock
    FROM products
    WHERE id = product_id;
    
    IF current_stock + quantity_change >= 0 THEN
        UPDATE products
        SET stock_quantity = stock_quantity + quantity_change,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = product_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '库存不足，无法减少指定数量';
    END IF;
END //

DELIMITER ;

-- 创建触发器示例

-- 订单创建后自动减少库存
DELIMITER //
CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE id = NEW.product_id;
END //
DELIMITER ;

-- 插入一些测试函数
DELIMITER //

-- 计算订单折扣的函数
CREATE FUNCTION CalculateDiscount(order_total DECIMAL(12,2)) 
RETURNS DECIMAL(8,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE discount DECIMAL(8,2) DEFAULT 0.00;
    
    IF order_total >= 10000 THEN
        SET discount = order_total * 0.10;  -- 10% 折扣
    ELSEIF order_total >= 5000 THEN
        SET discount = order_total * 0.05;  -- 5% 折扣
    ELSEIF order_total >= 1000 THEN
        SET discount = order_total * 0.02;  -- 2% 折扣
    END IF;
    
    RETURN discount;
END //

DELIMITER ;

-- 创建索引优化查询性能
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_products_category_status ON products(category_id, status);
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);

-- 插入一些示例配置数据
CREATE TABLE IF NOT EXISTS system_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO system_config (config_key, config_value, description) VALUES
('site_name', '测试商城', '网站名称'),
('default_currency', 'CNY', '默认货币'),
('tax_rate', '0.09', '税率'),
('free_shipping_threshold', '99.00', '免运费门槛'),
('max_cart_items', '50', '购物车最大商品数量'),
('session_timeout', '3600', '会话超时时间（秒）');

SELECT '数据库初始化完成！' as message;
SELECT '已创建以下表：users, categories, products, orders, order_items, shopping_cart, system_config' as tables_created;
SELECT '已创建视图：order_summary, low_stock_products, user_purchase_stats' as views_created;
SELECT '已创建存储过程：GetCartTotal, UpdateProductStock' as procedures_created;
SELECT '已创建函数：CalculateDiscount' as functions_created;