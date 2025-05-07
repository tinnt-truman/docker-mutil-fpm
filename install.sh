#!/bin/bash

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hiển thị tiêu đề
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    CÁCH NGƯỜI TA CÀI ĐẶT SITE     ${NC}"
echo -e "${BLUE}==========================================${NC}"

bash admin-setup.sh

bash service-setup.sh

# Xử lý cơ sở dữ liệu
echo -e "${YELLOW}⚙️ Đang cài đặt cơ sở dữ liệu...${NC}"

DB_USER="admin"
DB_PASSWORD="inan555vV~"
DB_ROOT_PASSWORD="inan555vV~"
DB_NAME="inanviet_client"

# Tạo file SQL tạm thời
cat << EOF > /tmp/service_init.sql
-- Tạo database nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Đảm bảo user tồn tại và cập nhật mật khẩu
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
ALTER USER '$DB_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';

-- Cấp quyền cho user
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

-- Áp dụng các thay đổi
FLUSH PRIVILEGES;

-- Hiển thị thông tin về databases để kiểm tra
SHOW DATABASES;
EOF

# Build và chạy containers
echo -e "${YELLOW}⚙️ Đang khởi tạo các containers...${NC}"
docker-compose up -d --build

# Đợi MySQL khởi động
echo -e "${YELLOW}⚙️ Đang đợi MySQL khởi động hoàn tất...${NC}"
sleep 10

# Cài đặt Laravel mới nếu chưa có file composer.json trong thư mục service
if [ ! -f "service/composer.json" ]; then
    echo -e "${YELLOW}⚙️ Đang tạo dự án Laravel mới...${NC}"
    docker exec inan_service_php_fpm composer create-project --prefer-dist laravel/laravel:^10.0 /tmp/laravel-temp

    if [ $? -eq 0 ]; then
        docker exec inan_service_php_fpm cp -r /tmp/laravel-temp/. /var/www/
        docker exec inan_service_php_fpm rm -rf /tmp/laravel-temp
        echo -e "${GREEN}✅ Đã tạo dự án Laravel mới${NC}"
    else
        echo -e "${RED}❌ Không thể tạo dự án Laravel mới. Vui lòng kiểm tra lại.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Dự án Laravel đã tồn tại${NC}"
fi

# Thực thi file SQL trong container MySQL (nếu container đang chạy)
if docker ps | grep -q mysql_database; then
    echo -e "${YELLOW}⚙️ Đang kết nối vào container MySQL...${NC}"
    docker exec -i mysql_database mysql -u root -p$DB_ROOT_PASSWORD < /tmp/service_init.sql

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Đã tạo thành công database và cấp quyền cho user.${NC}"
    else
        echo -e "${RED}❌ Có lỗi xảy ra khi tạo database. Vui lòng kiểm tra lại thông tin kết nối.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Container MySQL chưa chạy. Sẽ tạo database sau khi khởi động containers.${NC}"
fi

# Xóa file SQL tạm thời
rm /tmp/service_init.sql

# Cài đặt các dependencies cho dự án service
echo -e "${YELLOW}⚙️ Đang cài đặt các dependencies cho dự án service...${NC}"
docker exec inan_service_php_fpm composer install

# Cài đặt JWT Authentication
echo -e "${YELLOW}⚙️ Đang cài đặt JWT Authentication...${NC}"
docker exec inan_service_php_fpm composer require tymon/jwt-auth

# Tạo key cho ứng dụng Laravel
echo -e "${YELLOW}⚙️ Đang tạo key cho ứng dụng Laravel...${NC}"
docker exec inan_service_php_fpm php artisan key:generate

# Tạo secret key cho JWT
echo -e "${YELLOW}⚙️ Đang tạo secret key cho JWT...${NC}"
docker exec inan_service_php_fpm php artisan jwt:secret

# Chạy migration và seed
echo -e "${YELLOW}⚙️ Đang chạy migration và seeder...${NC}"
docker exec inan_service_php_fpm php artisan migrate
docker exec inan_service_php_fpm php artisan db:seed

# Tạo symbolic link cho thư mục storage
echo -e "${YELLOW}⚙️ Đang tạo symbolic link cho thư mục storage...${NC}"
docker exec inan_service_php_fpm php artisan storage:link

# Xóa cache
echo -e "${YELLOW}⚙️ Đang xóa cache...${NC}"
docker exec inan_service_php_fpm php artisan config:clear
docker exec inan_service_php_fpm php artisan route:clear
docker exec inan_service_php_fpm php artisan view:clear
docker exec inan_service_php_fpm php artisan cache:clear

# Thiết lập quyền
#echo -e "${YELLOW}⚙️ Đang thiết lập quyền cho thư mục...${NC}"
#docker exec inan_service_php_fpm chown -R www-data:www-data /var/www
#docker exec inan_service_php_fpm chmod -R 755 /var/www/public

# Xử lý cơ sở dữ liệu
echo -e "${YELLOW}⚙️ Đang cài đặt cơ sở dữ liệu...${NC}"

DB_USER="admin"
DB_PASSWORD="inan555vV~"
DB_ROOT_PASSWORD="inan555vV~"
DB_NAME="admin_inanviet"

# Tạo file SQL tạm thời
cat << EOF > /tmp/init.sql
-- Tạo database nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Đảm bảo user tồn tại và cập nhật mật khẩu
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
ALTER USER '$DB_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';

-- Cấp quyền cho user
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON \`inanviet_client\`.* TO '$DB_USER'@'%';

-- Áp dụng các thay đổi
FLUSH PRIVILEGES;

-- Hiển thị thông tin về databases để kiểm tra
SHOW DATABASES;
EOF

# Thực thi file SQL trong container MySQL (nếu container đang chạy)
if docker ps | grep -q mysql_database; then
    echo -e "${YELLOW}⚙️ Đang kết nối vào container MySQL...${NC}"
    docker exec -i mysql_database mysql -u root -p$DB_ROOT_PASSWORD < /tmp/init.sql

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Đã tạo thành công database và cấp quyền cho user.${NC}"
    else
        echo -e "${RED}❌ Có lỗi xảy ra khi tạo database. Vui lòng kiểm tra lại thông tin kết nối.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Container MySQL chưa chạy. Sẽ tạo database sau khi khởi động containers.${NC}"
fi

# Xóa file SQL tạm thời
rm /tmp/init.sql

# Cài đặt các dependencies cho dự án admin
echo -e "${YELLOW}⚙️ Đang cài đặt các dependencies cho dự án admin...${NC}"
docker exec admin_php_fpm composer install

# Tạo key cho ứng dụng Laravel
echo -e "${YELLOW}⚙️ Đang tạo key cho ứng dụng Laravel...${NC}"
docker exec admin_php_fpm php artisan key:generate

# Chạy migration và seed
echo -e "${YELLOW}⚙️ Đang chạy migration và seeder...${NC}"
docker exec admin_php_fpm php artisan migrate --force

# Tạo symbolic link cho thư mục storage
echo -e "${YELLOW}⚙️ Đang tạo symbolic link cho thư mục storage...${NC}"
docker exec admin_php_fpm php artisan storage:link

# Xóa cache
echo -e "${YELLOW}⚙️ Đang xóa cache...${NC}"
docker exec admin_php_fpm php artisan config:clear
docker exec admin_php_fpm php artisan route:clear
docker exec admin_php_fpm php artisan view:clear
docker exec admin_php_fpm php artisan cache:clear

# Thiết lập quyền
#echo -e "${YELLOW}⚙️ Đang thiết lập quyền cho thư mục...${NC}"
#docker exec admin_php_fpm chown -R www-data:www-data /var/www
#docker exec admin_php_fpm chmod -R 755 /var/www/public

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}    CÀI ĐẶT HOÀN TẤT THÀNH CÔNG!      ${NC}"
echo -e "${GREEN}=======================================${NC}"
echo -e "${BLUE}Admin site: http://localhost:8084${NC}"
echo -e "${BLUE}Service API: http://localhost:8083${NC}"
echo -e "${BLUE}Adminer: http://localhost:9080${NC}"
echo -e "${BLUE}- MySQL host: mysql${NC}"
echo -e "${BLUE}- MySQL user: $DB_USER${NC}"
echo -e "${BLUE}- MySQL password: $DB_PASSWORD${NC}"
echo -e "${BLUE}- MySQL database: $DB_NAME${NC}"
echo -e "${GREEN}=======================================${NC}"