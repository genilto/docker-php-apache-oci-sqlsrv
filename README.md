# docker-php-apache-oci-sqlsrv
Esta é uma imagem Docker com Apache e PHP com oracleclient e Extensões OCI8 e SQLSERV
Tudo configurado para rodar um ambiente Laravel dentro de /var/www/app
Já vem com o composer e com o node instalado também para instalação de dependências

# Para fazer o build da imagem:
```bash
docker build . --rm --tag genilto/php-apache-oci-sqlsrv:latest
```

# Para rodar o container manualmente, caso queira ver como ficou
```bash
docker run -p 80:80 -d genilto/php-apache-oci-sqlsrv:latest
```

# Caso queira rodar o compose, irá subir o mysql, app e um phpmyadmin
Ele ira fazer o build baseado na imagem criada anteriormente

```bash
docker-compose up -d
```

# Push para o docker hub
```bash
docker push genilto/php-apache-oci-sqlsrv:latest
```

# Criando a imagem para sua aplicação
Caso queira montar uma nova imagem com os arquivos do seu projeto laravel baseada nessa imagem você pode criar seu Dockerfile como abaixo
Este rodaria uma aplicação em Laravel, instalando as dependências necessarias do composer e do npm

```Dockerfile
FROM genilto/php-apache-oci-sqlsrv:latest

# Copy existing application directory permissions
COPY . .

# Install composer dependences
RUN composer install

# Install node dependences
RUN npm install

# Altera permissoes dos arquivos para o www-data do apache
RUN chown -R www-data:www-data ${APP_DOCUMENT_ROOT}
```

Após terminar, ao rodar o container, é possível rodar um migrate, caso necessário
```bash
docker exec docker-compose_app_1 php artisan migrate
```

# Teste de conexoes
Caso não possua uma aplicação Laravel, poderá simplesmente utilizar o public/index.php, configurando as vaiáveis com as informações do banco Oracle e SQLServer para teste de conexão

# COMPOSER
Também é possível subir um ambiente completo com Mysql, PhpMyAdmin e a sua aplicação, utilizando o docker-composer.
Para isso, basta rodar o comando abaixo para subir o ambiente
```bash
docker-composer up -d
```

Caso desejar, é possível definir o volume dos arquivos do projeto, de forma que o ambiente de desenvolvimento fique totalmente pronto para uso.