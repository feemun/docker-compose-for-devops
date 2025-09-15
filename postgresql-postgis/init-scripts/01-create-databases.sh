#!/bin/bash
set -e

# 创建多个数据库的脚本
# 这个脚本会在PostgreSQL容器首次启动时自动执行

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 创建maindb数据库（用于普通业务数据）
    CREATE DATABASE maindb;
    
    -- 创建gisdb数据库（用于空间数据）
    CREATE DATABASE gisdb;
    
    -- 为gisdb数据库创建专门的用户
    CREATE USER gisuser WITH PASSWORD 'gispassword';
    GRANT ALL PRIVILEGES ON DATABASE gisdb TO gisuser;
EOSQL

# 在gisdb数据库中启用PostGIS扩展
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "gisdb" <<-EOSQL
    -- 启用PostGIS扩展
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    CREATE EXTENSION IF NOT EXISTS postgis_raster;
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
    
    -- 授予gisuser用户对PostGIS相关表的权限
    GRANT ALL ON geometry_columns TO gisuser;
    GRANT ALL ON spatial_ref_sys TO gisuser;
    GRANT ALL ON geography_columns TO gisuser;
EOSQL

echo "数据库初始化完成："
echo "- postgres: 默认数据库"
echo "- maindb: 业务数据库"
echo "- gisdb: 空间数据库（已启用PostGIS扩展）"