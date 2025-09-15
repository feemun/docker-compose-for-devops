// MongoDB initialization script
// This script will be executed when MongoDB container starts for the first time

// Switch to admin database for authentication
db = db.getSiblingDB('admin');

// Authenticate as root user
db.auth('root', 'root');

// Create BaseMap database
db = db.getSiblingDB('BaseMap');
db.createCollection('init');
print('BaseMap database created successfully');

// Create Terrain database
db = db.getSiblingDB('Terrain');
db.createCollection('init');
print('Terrain database created successfully');

// Create a user for BaseMap database (optional, for better security)
db = db.getSiblingDB('BaseMap');
db.createUser({
  user: 'basemap_user',
  pwd: 'basemap_password',
  roles: [
    { role: 'readWrite', db: 'BaseMap' }
  ]
});

// Create a user for Terrain database (optional, for better security)
db = db.getSiblingDB('Terrain');
db.createUser({
  user: 'terrain_user',
  pwd: 'terrain_password',
  roles: [
    { role: 'readWrite', db: 'Terrain' }
  ]
});

print('Database initialization completed successfully');