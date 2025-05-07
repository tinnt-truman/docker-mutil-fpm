#!/bin/bash

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hiển thị tiêu đề
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    CÀI ĐẶT SERVICE API CHO INANVIET     ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Kiểm tra xem đã có thư mục service chưa
if [ ! -d "service" ]; then
    echo -e "${RED}❌ Thư mục 'service' không tồn tại.${NC}"

   exit 1
fi

# Chuyển đến thư mục service
cd service

# Kiểm tra file .env
echo -e "${YELLOW}⚙️ Đang kiểm tra file .env...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Đã tạo file .env từ .env.example${NC}"
    else
        cat > .env << EOF
APP_NAME=InAnVietService
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8083

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=inanviet_client
DB_USERNAME=admin
DB_PASSWORD=inan555vV~

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=null
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

JWT_SECRET=
JWT_TTL=60
JWT_REFRESH_TTL=20160
EOF
        echo -e "${GREEN}✅ Đã tạo file .env mới${NC}"
    fi
else
    echo -e "${GREEN}✅ File .env đã tồn tại${NC}"
fi

# Kiểm tra service-nginx.conf
echo -e "${YELLOW}⚙️ Đang kiểm tra file cấu hình Nginx...${NC}"
if [ ! -f "service-nginx.conf" ]; then
    cat > service-nginx.conf << 'EOF'
server {
    listen 80;
    index index.php index.html;
    root /var/www/public;
    
    error_log /var/log/nginx/error.log debug;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass service-php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
    
    # Cấu hình CORS cho API
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
    
    # Xử lý các request preflight OPTIONS
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
}
EOF
    echo -e "${GREEN}✅ Đã tạo file service-nginx.conf${NC}"
else
    echo -e "${GREEN}✅ File service-nginx.conf đã tồn tại${NC}"
fi

# Kiểm tra thư mục storage
echo -e "${YELLOW}⚙️ Đang thiết lập quyền cho thư mục storage...${NC}"
if [ -d "storage" ]; then
    chmod -R 777 storage
    echo -e "${GREEN}✅ Đã cập nhật quyền cho thư mục storage${NC}"
else
    echo -e "${YELLOW}⚠️ Thư mục storage chưa tồn tại. Sẽ được tạo sau khi cài đặt Laravel${NC}"
fi

# Tạo Dockerfile nếu chưa có
echo -e "${YELLOW}⚙️ Đang kiểm tra Dockerfile...${NC}"
if [ ! -f "Dockerfile" ]; then
    cat > Dockerfile << 'EOF'
FROM php:8.1-fpm

# Update package list and install required dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && apt-get clean

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

WORKDIR /var/www

EOF
    echo -e "${GREEN}✅ Đã tạo Dockerfile${NC}"
else
    echo -e "${GREEN}✅ Dockerfile đã tồn tại${NC}"
fi

# Trở về thư mục gốc
cd ..
