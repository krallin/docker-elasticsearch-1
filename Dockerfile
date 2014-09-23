FROM quay.io/aptible/ubuntu:14.04

RUN apt-get update

# Taken from dockerfile/java:oracle-java7
# Accept Oracle license agreement
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 " \
         "select true" | debconf-set-selections
# Install Java 7 and clean up
RUN apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && apt-get install -y oracle-java7-installer && \
    rm -rf /var/lib/apt/lists/*

# Install Elasticsearch and clean up
RUN apt-get -y install wget && cd /tmp && \
    wget http://bit.ly/elasticsearch-132 && tar xvzf elasticsearch-132 && \
    mv /tmp/elasticsearch-1.3.2 /elasticsearch && rm -rf elasticsearch-132

# Mount elasticsearch.yml config
ADD templates/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Install NGiNX
RUN add-apt-repository -y ppa:nginx/stable && apt-get update && \
    apt-get -y install nginx && mkdir -p /etc/nginx/ssl
ADD templates/nginx.conf /etc/nginx/nginx.conf
ADD templates/nginx-wrapper /usr/sbin/nginx-wrapper

# Integration tests
ADD test /tmp/test
RUN bats /tmp/test

VOLUME ["/data"]

# Expose NGiNX proxy ports
EXPOSE 80 443

CMD ["/usr/sbin/nginx-wrapper"]
