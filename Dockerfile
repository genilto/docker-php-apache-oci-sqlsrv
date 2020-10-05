FROM php:7.4-apache
LABEL maintainer "Genilto Vanzin <genilto.vanzin@gmail.com>"

# Adjust the document root for laravel app
ENV APP_DOCUMENT_ROOT="/var/www/app"
ENV APACHE_DOCUMENT_ROOT="${APP_DOCUMENT_ROOT}/public"

# Adjust paths for Oracle Instant Client
ENV ORACLE_BASE_PATH="/opt/oracle"
ENV LD_LIBRARY_PATH="${ORACLE_BASE_PATH}/instantclient"

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
 && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
###########################################################################
# APACHE CONFIGURATIONS
###########################################################################
 && a2enmod rewrite expires \
###########################################################################
# repositories for nodejs
###########################################################################
 && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
###########################################################################
# Add Repositories for SQL Server
###########################################################################
 && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
###########################################################################
# Install system dependencies
###########################################################################
 && apt-get update && export ACCEPT_EULA=Y && apt-get install -y \
    build-essential \
    git \
    curl \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zlib1g-dev \
    jpegoptim optipng pngquant gifsicle \
    locales \
    zip \
    unzip \
    nano \
    wget libaio1 \
    nodejs \
    msodbcsql17 \
    unixodbc-dev \
# Clean Apt cache
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
###########################################################################
# Install PHP extensions
###########################################################################
 && docker-php-ext-install \
    pdo_mysql \
    exif pcntl \
    bcmath \
    gd \
###########################################################################
# Install composer
###########################################################################
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

###########################################################################
# PHP OCI8
###########################################################################
RUN mkdir ${ORACLE_BASE_PATH} \
 && cd ${ORACLE_BASE_PATH} \
 && wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip \
 && wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip \
 && unzip /opt/oracle/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip -d ${ORACLE_BASE_PATH} \
 && unzip /opt/oracle/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip -d ${ORACLE_BASE_PATH} \
 && rm -rf ${ORACLE_BASE_PATH}/*.zip \
 && ln -s ${ORACLE_BASE_PATH}/instantclient_19_8 ${LD_LIBRARY_PATH} \
 && echo ${ORACLE_BASE_PATH}/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf \
 && ldconfig \
 && echo "instantclient,${LD_LIBRARY_PATH}" | pecl install oci8 \
 && docker-php-ext-enable oci8

###########################################################################
# PHP PDO_SQLSRV
###########################################################################
RUN pecl install sqlsrv \
 && pecl install pdo_sqlsrv \
 && docker-php-ext-enable sqlsrv pdo_sqlsrv

###########################################################################
# GAMBIARRA PARA BAIXAR A VERSAO DO OPENSSL E CONSEGUIR CONEXAO COM O SQL SERVER
# REMOVER ASSIM QUE POSSIVEL E UTILIZAR TLSv1.2
RUN sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1.0',g' /etc/ssl/openssl.cnf \
    && sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf
###########################################################################

RUN mkdir ${APP_DOCUMENT_ROOT}
#RUN mkdir ${APACHE_DOCUMENT_ROOT}

# Change the work directory to the new apache root path
WORKDIR ${APP_DOCUMENT_ROOT}

# Copy existing application directory permissions
COPY . .

# Altera permissoes dos arquivos para o www-data do apache
RUN chown -R www-data:www-data ${APP_DOCUMENT_ROOT}