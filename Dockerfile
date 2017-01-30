FROM centos:7
MAINTAINER NGINX Docker Maintainers
ENV NGINX_VERSION 1.11.9
RUN yum update -y && \
    yum install unzip wget gcc make git autoconf automake libtool patch pcre-devel zlib-devel which -y
RUN wget -O nginx-ct.zip -c https://github.com/grahamedgecombe/nginx-ct/archive/v1.3.2.zip && \
    unzip nginx-ct.zip
RUN git clone https://github.com/bagder/libbrotli
RUN cd libbrotli && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install
RUN git clone https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && \
    git submodule update --init
RUN git clone https://github.com/cloudflare/sslconfig.git
RUN wget -O openssl.tar.gz -c https://github.com/openssl/openssl/archive/OpenSSL_1_0_2j.tar.gz && \
    tar zxf openssl.tar.gz && \
    mv openssl-OpenSSL_1_0_2j/ openssl && \
    cd openssl && \
    patch -p1 < ../sslconfig/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch
RUN wget -c https://nginx.org/download/nginx-1.11.9.tar.gz && \
    tar zxf nginx-1.11.9.tar.gz && \
    cd nginx-1.11.9/ && \
    patch -p1 < ../sslconfig/patches/nginx__1.11.5_dynamic_tls_records.patch && \
    ./configure --add-module=../ngx_brotli --add-module=../nginx-ct-1.3.2 --with-openssl=../openssl --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module && \
    make && \
    make install && \
    cd ../

EXPOSE 80 443
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
