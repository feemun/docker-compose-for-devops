FROM openjdk:21-jdk

ENV HBASE_VERSION=2.5.11
ENV HBASE_HOME=/opt/hbase
ENV PATH=$PATH:$HBASE_HOME/bin

RUN apt-get update && apt-get install -y wget tar dnsutils && \
    rm -rf /var/lib/apt/lists/*

# 下载HBase
RUN mkdir -p /opt && \
    wget https://dlcdn.apache.org/hbase/2.5.11/hbase-2.5.11-bin.tar.gz -O /tmp/hbase.tar.gz && \
    tar -xzf /tmp/hbase.tar.gz -C /opt && \
    mv /opt/hbase-$HBASE_VERSION $HBASE_HOME && \
    rm /tmp/hbase.tar.gz

# 复制启动脚本
COPY bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh

# 暴露必要端口
EXPOSE 16000 16010 16020 16030 2181

CMD ["/bootstrap.sh"]
