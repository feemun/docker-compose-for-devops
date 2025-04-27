#!/bin/bash
set -e

# 如果挂载了 conf/hbase-site.xml，则覆盖进去
if [ -f "/conf/hbase-site.xml" ]; then
  echo "Using mounted hbase-site.xml..."
  cp /conf/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
fi

# 创建数据目录
mkdir -p /hbase-data /hbase-zookeeper

# 启动 HBase（不启动内置的 Zookeeper）
echo "Starting HBase (without embedded Zookeeper)..."
$HBASE_HOME/bin/start-hbase.sh

# 保持容器活着
tail -f $HBASE_HOME/logs/*.log