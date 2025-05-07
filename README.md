# Docker Multi-FPM

Dự án Laravel với nhiều container PHP-FPM độc lập. Giải pháp này cho phép chạy nhiều ứng dụng Laravel (Admin và Service)
trong cùng một môi trường Docker.

## Yêu cầu

- Docker và Docker Compose
- PHP 7.4 hoặc cao hơn
- Composer 2.0+
- Git

## Thiết lập và cài đặt

### Cài đặt trang quản trị (Admin)

<code>bash admin-setup.sh</code>

Lệnh này sẽ:

- Tạo môi trường Docker cho phần Admin
- Cài đặt các phụ thuộc của Laravel qua Composer
- Thiết lập cơ sở dữ liệu ban đầu
- Tạo khóa ứng dụng Laravel

### Cài đặt trang dịch vụ (Service)

<code>bash service_api_setup.sh</code>

Lệnh này sẽ cấu hình và cài đặt ứng dụng dịch vụ API của hệ thống.

### Cài đặt toàn bộ ứng dụng

<code>bash install.sh</code>

Lệnh này sẽ cài đặt cả hai ứng dụng Admin và Service cùng một lúc.

## Cấu trúc dự án

- `admin/`: Ứng dụng quản trị backend
- `service/`: Ứng dụng dịch vụ REST API
- `docker-compose.example.yml`: Mẫu cấu hình Docker
- `.env.example`: Mẫu cấu hình môi trường

## Truy cập ứng dụng

- Admin: http://localhost:8084
- Service API: http://localhost:8083
- Adminer (quản lý DB): http://localhost:9080

## Các lệnh hữu ích

### Truy cập MySQL CLI

<code>bash mysql.sh</code>

### Khởi động lại các container

<code>docker-compose restart</code>

### Xem log

<code>docker-compose logs -f</code>

## Xử lý sự cố

Nếu gặp lỗi trong quá trình cài đặt:

1. Kiểm tra log Docker: `docker compose logs -f`
2. Đảm bảo các cổng 8083, 8084 và 9080 không bị chiếm dụng
3. Kiểm tra quyền truy cập vào thư mục của dự án

## Đóng góp

Vui lòng tạo issue hoặc pull request trên repository chính thức để đóng góp vào dự án.

## Giấy phép

Dự án này được phân phối dưới giấy phép MIT.
