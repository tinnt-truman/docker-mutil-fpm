
DB_USER="admin"
DB_PASSWORD="s34Rt2gfL4d9"
DB_ROOT_PASSWORD="inan555vV~"

# Thực thi file SQL trong container MySQL
docker exec -it mysql_database bash

mysql -u root -p$DB_ROOT_PASSWORD

# Tạo lại user nếu cần
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 's34Rt2gfL4d9';

CREATE DATABASE IF NOT EXISTS admin_inanviet;

# Cấp quyền cho user admin
GRANT ALL PRIVILEGES ON admin_inanviet.* TO 'admin'@'%';
GRANT ALL PRIVILEGES ON inanviet_client.* TO 'admin'@'%';

# Cập nhật mật khẩu cho user
ALTER USER 'admin'@'%' IDENTIFIED WITH mysql_native_password BY 's34Rt2gfL4d9';

# Áp dụng các thay đổi
FLUSH PRIVILEGES;

