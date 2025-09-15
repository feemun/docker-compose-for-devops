// MongoDB initialization script
// This script will be executed when MongoDB container starts for the first time

// Switch to admin database for authentication
db = db.getSiblingDB('admin');

// Authenticate as root user
db.auth('root', 'root');

// Create test database
db = db.getSiblingDB('test');

// Create users collection with sample data
db.users.insertMany([
  {
    _id: ObjectId(),
    username: 'john_doe',
    email: 'john@example.com',
    age: 28,
    city: 'New York',
    interests: ['technology', 'sports', 'music'],
    createdAt: new Date('2024-01-15'),
    isActive: true
  },
  {
    _id: ObjectId(),
    username: 'jane_smith',
    email: 'jane@example.com',
    age: 32,
    city: 'Los Angeles',
    interests: ['travel', 'photography', 'cooking'],
    createdAt: new Date('2024-01-20'),
    isActive: true
  },
  {
    _id: ObjectId(),
    username: 'bob_wilson',
    email: 'bob@example.com',
    age: 25,
    city: 'Chicago',
    interests: ['gaming', 'movies', 'books'],
    createdAt: new Date('2024-02-01'),
    isActive: false
  },
  {
    _id: ObjectId(),
    username: 'alice_brown',
    email: 'alice@example.com',
    age: 29,
    city: 'San Francisco',
    interests: ['art', 'design', 'yoga'],
    createdAt: new Date('2024-02-10'),
    isActive: true
  },
  {
    _id: ObjectId(),
    username: 'charlie_davis',
    email: 'charlie@example.com',
    age: 35,
    city: 'Seattle',
    interests: ['hiking', 'coffee', 'programming'],
    createdAt: new Date('2024-02-15'),
    isActive: true
  }
]);
print('Users collection created with sample data');

// Create products collection with sample data
db.products.insertMany([
  {
    _id: ObjectId(),
    name: 'iPhone 15 Pro',
    category: 'Electronics',
    price: 999.99,
    stock: 50,
    description: 'Latest iPhone with advanced features',
    tags: ['smartphone', 'apple', 'mobile'],
    rating: 4.8,
    reviews: 1250,
    createdAt: new Date('2024-01-10')
  },
  {
    _id: ObjectId(),
    name: 'MacBook Air M3',
    category: 'Electronics',
    price: 1299.99,
    stock: 30,
    description: 'Lightweight laptop with M3 chip',
    tags: ['laptop', 'apple', 'computer'],
    rating: 4.9,
    reviews: 890,
    createdAt: new Date('2024-01-12')
  },
  {
    _id: ObjectId(),
    name: 'Nike Air Max 270',
    category: 'Shoes',
    price: 150.00,
    stock: 100,
    description: 'Comfortable running shoes',
    tags: ['shoes', 'nike', 'running'],
    rating: 4.5,
    reviews: 2100,
    createdAt: new Date('2024-01-15')
  },
  {
    _id: ObjectId(),
    name: 'Samsung 4K TV',
    category: 'Electronics',
    price: 799.99,
    stock: 25,
    description: '55-inch 4K Smart TV',
    tags: ['tv', 'samsung', '4k'],
    rating: 4.6,
    reviews: 650,
    createdAt: new Date('2024-01-18')
  },
  {
    _id: ObjectId(),
    name: 'Adidas Ultraboost 22',
    category: 'Shoes',
    price: 180.00,
    stock: 75,
    description: 'Premium running shoes with boost technology',
    tags: ['shoes', 'adidas', 'running'],
    rating: 4.7,
    reviews: 1800,
    createdAt: new Date('2024-01-20')
  }
]);
print('Products collection created with sample data');

// Create orders collection with sample data
db.orders.insertMany([
  {
    _id: ObjectId(),
    userId: 'john_doe',
    orderNumber: 'ORD-2024-001',
    items: [
      { productName: 'iPhone 15 Pro', quantity: 1, price: 999.99 },
      { productName: 'Nike Air Max 270', quantity: 2, price: 150.00 }
    ],
    totalAmount: 1299.99,
    status: 'completed',
    shippingAddress: {
      street: '123 Main St',
      city: 'New York',
      state: 'NY',
      zipCode: '10001'
    },
    orderDate: new Date('2024-02-01'),
    deliveryDate: new Date('2024-02-05')
  },
  {
    _id: ObjectId(),
    userId: 'jane_smith',
    orderNumber: 'ORD-2024-002',
    items: [
      { productName: 'MacBook Air M3', quantity: 1, price: 1299.99 }
    ],
    totalAmount: 1299.99,
    status: 'shipped',
    shippingAddress: {
      street: '456 Oak Ave',
      city: 'Los Angeles',
      state: 'CA',
      zipCode: '90210'
    },
    orderDate: new Date('2024-02-10'),
    deliveryDate: null
  },
  {
    _id: ObjectId(),
    userId: 'alice_brown',
    orderNumber: 'ORD-2024-003',
    items: [
      { productName: 'Samsung 4K TV', quantity: 1, price: 799.99 },
      { productName: 'Adidas Ultraboost 22', quantity: 1, price: 180.00 }
    ],
    totalAmount: 979.99,
    status: 'processing',
    shippingAddress: {
      street: '789 Pine St',
      city: 'San Francisco',
      state: 'CA',
      zipCode: '94102'
    },
    orderDate: new Date('2024-02-15'),
    deliveryDate: null
  }
]);
print('Orders collection created with sample data');

// Create categories collection
db.categories.insertMany([
  {
    _id: ObjectId(),
    name: 'Electronics',
    description: 'Electronic devices and gadgets',
    parentCategory: null,
    isActive: true,
    createdAt: new Date('2024-01-01')
  },
  {
    _id: ObjectId(),
    name: 'Shoes',
    description: 'Footwear for all occasions',
    parentCategory: null,
    isActive: true,
    createdAt: new Date('2024-01-01')
  },
  {
    _id: ObjectId(),
    name: 'Smartphones',
    description: 'Mobile phones and accessories',
    parentCategory: 'Electronics',
    isActive: true,
    createdAt: new Date('2024-01-01')
  },
  {
    _id: ObjectId(),
    name: 'Laptops',
    description: 'Portable computers',
    parentCategory: 'Electronics',
    isActive: true,
    createdAt: new Date('2024-01-01')
  }
]);
print('Categories collection created with sample data');

// Create indexes for better performance
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ city: 1 });
db.users.createIndex({ createdAt: -1 });

db.products.createIndex({ name: 1 });
db.products.createIndex({ category: 1 });
db.products.createIndex({ price: 1 });
db.products.createIndex({ tags: 1 });
db.products.createIndex({ createdAt: -1 });

db.orders.createIndex({ userId: 1 });
db.orders.createIndex({ orderNumber: 1 }, { unique: true });
db.orders.createIndex({ status: 1 });
db.orders.createIndex({ orderDate: -1 });

db.categories.createIndex({ name: 1 }, { unique: true });
db.categories.createIndex({ parentCategory: 1 });

print('Indexes created successfully');

// Create a user for test database (optional, for better security)
db.createUser({
  user: 'test_user',
  pwd: 'test_password',
  roles: [
    { role: 'readWrite', db: 'test' }
  ]
});

print('Test database initialization completed successfully');