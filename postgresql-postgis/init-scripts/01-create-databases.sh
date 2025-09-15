#!/bin/bash
set -e

# PostgreSQL + PostGIS 测试数据初始化脚本
# 创建两个数据库：普通业务数据库和PostGIS空间数据库，并生成测试数据

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 创建testdb数据库（普通业务数据库）
    CREATE DATABASE testdb;
    
    -- 创建gisdb数据库（PostGIS空间数据库）
    CREATE DATABASE gisdb;
    
    -- 创建普通数据库用户
    CREATE USER testuser WITH PASSWORD 'testpass';
    GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;
    
    -- 创建PostGIS数据库用户
    CREATE USER gisuser WITH PASSWORD 'gispass';
    GRANT ALL PRIVILEGES ON DATABASE gisdb TO gisuser;
EOSQL

# 在testdb数据库中创建测试数据
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "testdb" <<-EOSQL
    -- 创建用户表
    CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100),
        phone VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT true
    );
    
    -- 创建分类表
    CREATE TABLE categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        parent_id INTEGER REFERENCES categories(id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- 创建产品表
    CREATE TABLE products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        stock_quantity INTEGER DEFAULT 0,
        category_id INTEGER REFERENCES categories(id),
        sku VARCHAR(50) UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT true
    );
    
    -- 创建订单表
    CREATE TABLE orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        order_number VARCHAR(50) UNIQUE NOT NULL,
        total_amount DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        shipping_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- 创建订单项表
    CREATE TABLE order_items (
        id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES orders(id),
        product_id INTEGER REFERENCES products(id),
        quantity INTEGER NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        total_price DECIMAL(10,2) NOT NULL
    );
    
    -- 插入测试数据
    -- 用户数据
    INSERT INTO users (username, email, password_hash, full_name, phone) VALUES
    ('john_doe', 'john@example.com', 'hashed_password_1', 'John Doe', '+1234567890'),
    ('jane_smith', 'jane@example.com', 'hashed_password_2', 'Jane Smith', '+1234567891'),
    ('bob_wilson', 'bob@example.com', 'hashed_password_3', 'Bob Wilson', '+1234567892'),
    ('alice_brown', 'alice@example.com', 'hashed_password_4', 'Alice Brown', '+1234567893'),
    ('charlie_davis', 'charlie@example.com', 'hashed_password_5', 'Charlie Davis', '+1234567894');
    
    -- 分类数据
    INSERT INTO categories (name, description) VALUES
    ('Electronics', 'Electronic devices and accessories'),
    ('Clothing', 'Apparel and fashion items'),
    ('Books', 'Books and educational materials'),
    ('Home & Garden', 'Home improvement and garden supplies'),
    ('Sports', 'Sports equipment and accessories');
    
    INSERT INTO categories (name, description, parent_id) VALUES
    ('Smartphones', 'Mobile phones and accessories', 1),
    ('Laptops', 'Portable computers', 1),
    ('Men Clothing', 'Clothing for men', 2),
    ('Women Clothing', 'Clothing for women', 2);
    
    -- 产品数据
    INSERT INTO products (name, description, price, stock_quantity, category_id, sku) VALUES
    ('iPhone 15 Pro', 'Latest Apple smartphone with advanced features', 999.99, 50, 6, 'IPH15PRO001'),
    ('MacBook Air M2', 'Lightweight laptop with M2 chip', 1199.99, 30, 7, 'MBA-M2-001'),
    ('Samsung Galaxy S24', 'Android flagship smartphone', 899.99, 40, 6, 'SGS24-001'),
    ('Dell XPS 13', 'Premium ultrabook laptop', 1099.99, 25, 7, 'DXPS13-001'),
    ('Nike Air Max', 'Comfortable running shoes', 129.99, 100, 5, 'NAM-001'),
    ('Programming Book', 'Learn advanced programming concepts', 49.99, 200, 3, 'PROG-BOOK-001'),
    ('Wireless Headphones', 'Bluetooth noise-canceling headphones', 199.99, 75, 1, 'WH-BT-001'),
    ('Cotton T-Shirt', 'Comfortable cotton t-shirt', 19.99, 150, 8, 'CT-SHIRT-001');
    
    -- 订单数据
    INSERT INTO orders (user_id, order_number, total_amount, status, shipping_address) VALUES
    (1, 'ORD-2024-001', 1199.98, 'completed', '123 Main St, New York, NY 10001'),
    (2, 'ORD-2024-002', 949.98, 'shipped', '456 Oak Ave, Los Angeles, CA 90210'),
    (3, 'ORD-2024-003', 179.98, 'pending', '789 Pine Rd, Chicago, IL 60601'),
    (4, 'ORD-2024-004', 1299.98, 'processing', '321 Elm St, Houston, TX 77001'),
    (5, 'ORD-2024-005', 69.98, 'completed', '654 Maple Dr, Phoenix, AZ 85001');
    
    -- 订单项数据
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
    (1, 1, 1, 999.99, 999.99),
    (1, 7, 1, 199.99, 199.99),
    (2, 3, 1, 899.99, 899.99),
    (2, 6, 1, 49.99, 49.99),
    (3, 5, 1, 129.99, 129.99),
    (3, 8, 2, 19.99, 39.98),
    (4, 2, 1, 1199.99, 1199.99),
    (4, 7, 1, 199.99, 199.99),
    (5, 6, 1, 49.99, 49.99),
    (5, 8, 1, 19.99, 19.99);
    
    -- 创建索引优化查询性能
    CREATE INDEX idx_users_email ON users(email);
    CREATE INDEX idx_users_username ON users(username);
    CREATE INDEX idx_products_category ON products(category_id);
    CREATE INDEX idx_products_sku ON products(sku);
    CREATE INDEX idx_orders_user ON orders(user_id);
    CREATE INDEX idx_orders_status ON orders(status);
    CREATE INDEX idx_order_items_order ON order_items(order_id);
    CREATE INDEX idx_order_items_product ON order_items(product_id);
    
    -- 授予testuser用户权限
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO testuser;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO testuser;
EOSQL

# 在gisdb数据库中启用PostGIS扩展并创建空间测试数据
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "gisdb" <<-EOSQL
    -- 启用PostGIS扩展
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    CREATE EXTENSION IF NOT EXISTS postgis_raster;
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
    
    -- 创建城市表（点数据）
    CREATE TABLE cities (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        country VARCHAR(100) NOT NULL,
        population INTEGER,
        geom GEOMETRY(POINT, 4326),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- 创建道路表（线数据）
    CREATE TABLE roads (
        id SERIAL PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        road_type VARCHAR(50),
        length_km DECIMAL(10,2),
        geom GEOMETRY(LINESTRING, 4326),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- 创建区域表（面数据）
    CREATE TABLE districts (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        district_type VARCHAR(50),
        area_km2 DECIMAL(10,2),
        geom GEOMETRY(POLYGON, 4326),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- 创建兴趣点表（POI）
    CREATE TABLE points_of_interest (
        id SERIAL PRIMARY KEY,
        name VARCHAR(200) NOT NULL,
        category VARCHAR(100),
        description TEXT,
        address VARCHAR(300),
        geom GEOMETRY(POINT, 4326),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- 插入城市测试数据（世界主要城市）
    INSERT INTO cities (name, country, population, geom) VALUES
    ('北京', '中国', 21540000, ST_GeomFromText('POINT(116.4074 39.9042)', 4326)),
    ('上海', '中国', 24280000, ST_GeomFromText('POINT(121.4737 31.2304)', 4326)),
    ('纽约', '美国', 8336817, ST_GeomFromText('POINT(-74.0060 40.7128)', 4326)),
    ('伦敦', '英国', 8982000, ST_GeomFromText('POINT(-0.1276 51.5074)', 4326)),
    ('东京', '日本', 13960000, ST_GeomFromText('POINT(139.6917 35.6895)', 4326)),
    ('巴黎', '法国', 2161000, ST_GeomFromText('POINT(2.3522 48.8566)', 4326)),
    ('悉尼', '澳大利亚', 5312000, ST_GeomFromText('POINT(151.2093 -33.8688)', 4326)),
    ('莫斯科', '俄罗斯', 12506000, ST_GeomFromText('POINT(37.6173 55.7558)', 4326));
    
    -- 插入道路测试数据
    INSERT INTO roads (name, road_type, length_km, geom) VALUES
    ('长安街', '主干道', 13.4, ST_GeomFromText('LINESTRING(116.3683 39.9042, 116.4074 39.9042, 116.4465 39.9042)', 4326)),
    ('南京路', '商业街', 5.5, ST_GeomFromText('LINESTRING(121.4737 31.2304, 121.4837 31.2304, 121.4937 31.2304)', 4326)),
    ('Broadway', '大道', 21.0, ST_GeomFromText('LINESTRING(-74.0060 40.7128, -73.9960 40.7228, -73.9860 40.7328)', 4326)),
    ('Oxford Street', '购物街', 2.4, ST_GeomFromText('LINESTRING(-0.1376 51.5074, -0.1276 51.5074, -0.1176 51.5074)', 4326));
    
    -- 插入区域测试数据
    INSERT INTO districts (name, district_type, area_km2, geom) VALUES
    ('朝阳区', '行政区', 470.8, ST_GeomFromText('POLYGON((116.4074 39.9042, 116.5074 39.9042, 116.5074 39.8042, 116.4074 39.8042, 116.4074 39.9042))', 4326)),
    ('浦东新区', '新区', 1210.4, ST_GeomFromText('POLYGON((121.4737 31.2304, 121.5737 31.2304, 121.5737 31.1304, 121.4737 31.1304, 121.4737 31.2304))', 4326)),
    ('曼哈顿', '行政区', 59.1, ST_GeomFromText('POLYGON((-74.0160 40.7028, -73.9960 40.7028, -73.9960 40.7228, -74.0160 40.7228, -74.0160 40.7028))', 4326)),
    ('Westminster', '行政区', 21.5, ST_GeomFromText('POLYGON((-0.1376 51.4974, -0.1176 51.4974, -0.1176 51.5174, -0.1376 51.5174, -0.1376 51.4974))', 4326));
    
    -- 插入兴趣点测试数据
    INSERT INTO points_of_interest (name, category, description, address, geom) VALUES
    ('天安门广场', '历史景点', '中国北京的著名广场', '北京市东城区东长安街', ST_GeomFromText('POINT(116.3974 39.9042)', 4326)),
    ('外滩', '观光景点', '上海著名的滨江景观带', '上海市黄浦区中山东一路', ST_GeomFromText('POINT(121.4937 31.2304)', 4326)),
    ('自由女神像', '地标', '纽约港的著名雕像', 'Liberty Island, New York, NY', ST_GeomFromText('POINT(-74.0445 40.6892)', 4326)),
    ('大本钟', '历史建筑', '伦敦威斯敏斯特宫的钟楼', 'Westminster, London SW1A 0AA, UK', ST_GeomFromText('POINT(-0.1246 51.4994)', 4326)),
    ('东京塔', '观光塔', '东京的标志性建筑', '日本东京都港区芝公园', ST_GeomFromText('POINT(139.7454 35.6586)', 4326)),
    ('埃菲尔铁塔', '地标', '巴黎的象征性建筑', 'Champ de Mars, 5 Avenue Anatole France, 75007 Paris', ST_GeomFromText('POINT(2.2945 48.8584)', 4326)),
    ('悉尼歌剧院', '文化建筑', '世界著名的表演艺术中心', 'Bennelong Point, Sydney NSW 2000, Australia', ST_GeomFromText('POINT(151.2153 -33.8568)', 4326)),
    ('红场', '历史广场', '莫斯科的中央广场', 'Red Square, Moscow, Russia', ST_GeomFromText('POINT(37.6201 55.7539)', 4326));
    
    -- 创建空间索引
    CREATE INDEX idx_cities_geom ON cities USING GIST (geom);
    CREATE INDEX idx_roads_geom ON roads USING GIST (geom);
    CREATE INDEX idx_districts_geom ON districts USING GIST (geom);
    CREATE INDEX idx_poi_geom ON points_of_interest USING GIST (geom);
    
    -- 创建普通索引
    CREATE INDEX idx_cities_country ON cities(country);
    CREATE INDEX idx_roads_type ON roads(road_type);
    CREATE INDEX idx_districts_type ON districts(district_type);
    CREATE INDEX idx_poi_category ON points_of_interest(category);
    
    -- 授予gisuser用户权限
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gisuser;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gisuser;
    GRANT ALL ON geometry_columns TO gisuser;
    GRANT ALL ON spatial_ref_sys TO gisuser;
    GRANT ALL ON geography_columns TO gisuser;
EOSQL

echo "数据库初始化完成："
echo "- postgres: 默认数据库"
echo "- testdb: 普通业务数据库（包含用户、产品、订单等测试数据）"
echo "- gisdb: PostGIS空间数据库（包含城市、道路、区域、兴趣点等空间测试数据）"
echo ""
echo "数据库用户："
echo "- postgres/postgres: 超级用户"
echo "- testuser/testpass: 普通数据库用户"
echo "- gisuser/gispass: PostGIS数据库用户"