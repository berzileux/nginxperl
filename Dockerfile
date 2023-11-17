FROM centos:centos7

MAINTAINER "bersileus" <bersileus@gmail.com>

ENV PERL_VERSION=5.38.0
ENV NGINX_VERSION=1.25.3

WORKDIR /shared

# Install prerequisites for perl compile we would be using
# the default of os-perl-for running nginx-perl modules
RUN yum -y install gcc gcc-c++  make
ADD http://www.cpan.org/src/5.0/perl-$PERL_VERSION.tar.gz /shared
RUN tar -xzf perl-$PERL_VERSION.tar.gz

WORKDIR /shared/perl-$PERL_VERSION
RUN ./Configure -des -Dprefix=/opt/perl/localperl

RUN make && \
    make install

WORKDIR /tmp

# Install prerequisites for Nginx compile
RUN yum install -y \
        which \
        shadow-utils \
        wget \
        tar \
        openssl-devel \
        zlib-devel \
        pcre-devel \
        gd-devel \
        krb5-devel \
        git \
		rpm-build \
		pcre-devel \
		zlib-devel \
		openssl-devel \
		glibc-headers

# Download Nginx and modules
RUN mkdir /tmp/nginx

RUN wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.35.tar.gz -O headers-more-nginx-module.tar.gz && \
    mkdir /tmp/nginx/headers-more-nginx-module && \
    tar -xzvf headers-more-nginx-module.tar.gz -C /tmp/nginx/headers-more-nginx-module --strip-components=1

RUN wget https://github.com/Martchus/nginx-accesskey/archive/refs/tags/v2.0.5.tar.gz -O nginx-accesskey.tar.gz && \
    mkdir /tmp/nginx/nginx-accesskey && \
    tar -xzvf nginx-accesskey.tar.gz -C /tmp/nginx/nginx-accesskey --strip-components=1

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -O nginx.tar.gz && \
    tar -xzvf nginx.tar.gz -C /tmp/nginx --strip-components=1 &&\
    git clone https://github.com/stnoonan/spnego-http-auth-nginx-module.git nginx/spnego-http-auth-nginx-module

# Build Nginx
WORKDIR /tmp/nginx

RUN ./configure \
    --with-debug \
    --user=nginx \
    --group=nginx \
    --prefix=/var/nginx/www/ \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/log/nginx/client_body \
    --http-proxy-temp-path=/var/log/nginx/proxy \
    --http-fastcgi-temp-path=/var/log/nginx/fastcgi \
    --http-uwsgi-temp-path=/var/log/nginx/uwsgi \
    --http-scgi-temp-path=/var/log/nginx/scgi \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_stub_status_module \
    --with-http_dav_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
	--with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_perl_module \
	--with-perl_modules_path=/opt/nginx-perl/modules/ \
    --with-perl=/opt/perl/localperl/bin/perl \
    --with-mail \
    --with-ipv6 \
    --with-mail_ssl_module \
    --with-pcre \
    --with-http_image_filter_module \
    --with-file-aio \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --add-module=nginx-accesskey \
    --add-module=headers-more-nginx-module \
    --add-module=spnego-http-auth-nginx-module \
    --with-cc-opt="-Wno-error $(pcre-config --cflags)" && \
	make && make install


RUN curl -L https://cpanmin.us/ -o cpanm && \
    chmod +x cpanm && \
    mv cpanm /bin/cpanm

# Cleanup after Nginx build
RUN rm -rf /tmp/*

# Configure filesystem to support running Nginx
RUN adduser -c "Nginx user" nginx && \
    setcap cap_net_bind_service=ep /usr/sbin/nginx

# Apply Nginx configuration
COPY defaults/config/. /etc/nginx/
COPY defaults/html/. /var/nginx/www/html/

# Set access rights
ADD defaults/bin/nginx-start /opt/bin/nginx-start

RUN chmod u=rwx /opt/bin/nginx-start && \
       chown -R nginx:nginx /opt/bin/nginx-start \
            /opt/nginx-perl/modules/ \
    		/etc/nginx \
    		/etc/nginx/nginx.conf \
    		/var/log/nginx \
    		/var/nginx/www/ \
    		/opt/perl

# Install at least default perl modules
ENV PATH="/opt/perl/localperl/bin:${PATH}"

RUN cpanm aliased && \
    cpanm ExtUtils::Embed && \
    cpanm Try::Tiny && \
    cpanm Log::Log4perl

# DATA VOLUMES
RUN mkdir -p /var/nginx/www/
VOLUME ["/var/nginx/www/"]

VOLUME ["/etc/nginx/"]
VOLUME ["/opt/nginx-perl/modules/x86_64-linux"]

WORKDIR /opt/nginx-perl/modules



# PORTS
EXPOSE 80
EXPOSE 443

USER nginx
#ENTRYPOINT ["/opt/bin/nginx-start"]
CMD ["nginx","-g", "daemon off;"]