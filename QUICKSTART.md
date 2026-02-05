# Quick Start Guide - Backend

## مراحل اجرای پروژه

### 1. نصب Dependencies

```bash
cd backend
go mod download
go mod tidy
```

### 2. نصب SQLC

```bash
# macOS/Linux
brew install sqlc

# یا
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# Windows
# دانلود از https://github.com/sqlc-dev/sqlc/releases
```

### 3. راه‌اندازی دیتابیس

#### با Docker:
```bash
# از ریشه پروژه
docker-compose up -d postgres redis

# صبر کنید تا postgres آماده شود
docker-compose logs -f postgres
```

#### بدون Docker:
```bash
# نصب PostgreSQL و Redis
# سپس ایجاد دیتابیس
createdb rxst

# اجرای schema
psql -d rxst -f ../database_schema.sql
```

### 4. تنظیم Configuration

```bash
# ویرایش فایل config
nano configs/config.yaml

# اطلاعات دیتابیس خود را وارد کنید:
database:
  host: localhost
  port: 5432
  user: postgres
  password: postgres
  dbname: rxst
```

### 5. Generate SQLC Code

```bash
# از دایرکتوری backend
sqlc generate

# اگر خطا گرفتید، مطمئن شوید که:
# 1. فایل sqlc.yaml در دایرکتوری backend وجود دارد
# 2. مسیر schema در sqlc.yaml درست است
# 3. فایل‌های .sql در internal/repository/queries/ وجود دارند
```

### 6. اجرای برنامه

```bash
# با Make
make run

# یا مستقیم با Go
go run cmd/api/main.go
```

### 7. تست کردن

```bash
# Health check
curl http://localhost:8080/health

# Login (ابتدا باید یک کاربر admin دستی در دیتابیس بسازید)
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

## ساخت کاربر Admin اولیه

```sql
-- در PostgreSQL:
-- 1. ابتدا یک Entity بسازید
INSERT INTO entities (entity_type, code, first_name, last_name, is_active)
VALUES ('person', 'ADMIN001', 'Admin', 'User', true);

-- 2. سپس یک User بسازید
-- Password: admin123 (bcrypt hash)
INSERT INTO users (
    entity_id, 
    username, 
    password_hash, 
    mobile_number, 
    is_system_admin, 
    is_active, 
    is_approved
)
SELECT 
    id,
    'admin',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIiC3L.lRC',
    '09123456789',
    true,
    true,
    true
FROM entities WHERE code = 'ADMIN001';
```

## دستورات مفید Make

```bash
make help              # نمایش تمام دستورات
make deps              # نصب dependencies
make sqlc              # Generate SQLC code
make run               # اجرای برنامه
make build             # Build برنامه
make test              # اجرای تست‌ها
make clean             # پاکسازی
make docker-up         # راه‌اندازی Docker
make docker-down       # خاموش کردن Docker
make dev               # راه‌اندازی کامل development
```

## ساختار پروژه

```
backend/
├── cmd/api/                    # Entry point
│   └── main.go                ✅
├── configs/
│   └── config.yaml            ✅
├── internal/
│   ├── api/
│   │   └── routes.go          ✅
│   ├── cache/
│   │   └── redis_cache.go     ✅
│   ├── config/
│   │   └── config.go          ✅
│   ├── database/
│   │   └── postgres.go        ✅
│   ├── domain/
│   │   ├── user.go            ✅
│   │   └── product.go         ✅
│   ├── dto/
│   │   ├── auth_dto.go        ✅
│   │   └── common_dto.go      ✅
│   ├── handler/
│   │   └── auth_handler.go    ✅
│   ├── middleware/
│   │   └── auth.go            ✅
│   ├── repository/
│   │   ├── queries/           ✅
│   │   │   ├── auth.sql
│   │   │   ├── entity.sql
│   │   │   ├── product.sql
│   │   │   └── inventory.sql
│   │   └── (generated)        ⏳ بعد از sqlc generate
│   └── service/
│       └── auth_service.go    ✅
├── pkg/
│   ├── logger/
│   │   └── logger.go          ✅
│   └── errors/
│       └── errors.go          ✅
├── go.mod                     ✅
├── sqlc.yaml                  ✅
└── Makefile                   ✅
```

## Endpoints موجود

### Public
- `POST /api/v1/auth/login` - ورود به سیستم
- `POST /api/v1/auth/register` - ثبت‌نام
- `POST /api/v1/auth/refresh` - تازه‌سازی توکن

### Protected (نیاز به توکن)
- `GET /api/v1/auth/profile` - پروفایل کاربر
- `POST /api/v1/auth/logout` - خروج
- `POST /api/v1/auth/change-password` - تغییر رمز عبور

### Admin Only
- `POST /api/v1/admin/approve-user` - تایید کاربر

## نکات مهم

### 1. SQLC
- هر بار که SQL query اضافه یا تغییر می‌دهید، باید `sqlc generate` را اجرا کنید
- فایل‌های generated نباید دستی ویرایش شوند

### 2. Migration
- برای تغییرات schema، از migrations استفاده کنید
- دستور: `make migrate-create name=add_new_table`

### 3. Error Handling
- همیشه از `pkg/errors` استفاده کنید
- Error های custom با context مناسب برگردانید

### 4. Logging
- از `pkg/logger` برای logging استفاده کنید
- Log level را در config.yaml تنظیم کنید

### 5. Testing
```bash
# تست یک package خاص
go test -v ./internal/service/

# تست با coverage
go test -cover ./...
```

## توسعه بعدی

### فایل‌هایی که باید اضافه شوند:

1. **Entity Service & Handler**
   - `internal/service/entity_service.go`
   - `internal/handler/entity_handler.go`

2. **Product Service & Handler**
   - `internal/service/product_service.go`
   - `internal/handler/product_handler.go`

3. **Inventory Service**
   - `internal/service/inventory_service.go`
   - `internal/cache/inventory_cache.go`

4. **RX Order Service & Handler**
   - `internal/service/rx_order_service.go`
   - `internal/handler/rx_order_handler.go`
   - SQL queries در `internal/repository/queries/rx_order.sql`

5. **ST Order Service & Handler**
   - مشابه RX Order

6. **Pricing Service**
   - `internal/service/pricing_service.go`
   - SQL queries برای price rules

7. **State Machine Service**
   - `internal/service/state_machine_service.go`

## مثال استفاده از API

```javascript
// 1. Login
const loginResponse = await fetch('http://localhost:8080/api/v1/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'admin',
    password: 'admin123'
  })
});
const { access_token } = await loginResponse.json();

// 2. Get Profile
const profileResponse = await fetch('http://localhost:8080/api/v1/auth/profile', {
  headers: {
    'Authorization': `Bearer ${access_token}`
  }
});
const profile = await profileResponse.json();
```

## Troubleshooting

### خطا: "command not found: sqlc"
```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

### خطا: "connection refused" به PostgreSQL
```bash
# بررسی وضعیت
docker-compose ps

# مشاهده logs
docker-compose logs postgres
```

### خطا در Generate SQLC
```bash
# بررسی syntax SQL files
sqlc verify

# حذف کدهای generated و دوباره generate
rm -rf internal/repository/*.go
sqlc generate
```

## مراحل بعدی

1. ✅ Authentication کامل شد
2. ⏳ Entity Management
3. ⏳ Product Management
4. ⏳ Inventory System
5. ⏳ RX Orders
6. ⏳ ST Orders
7. ⏳ Pricing Engine
8. ⏳ Financial Integration

برای هر بخش می‌توانید از الگوی Auth Service/Handler استفاده کنید.
