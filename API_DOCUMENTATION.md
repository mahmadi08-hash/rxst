# API Documentation - RX-ST System

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication

تمام endpoint های protected نیاز به Bearer Token دارند:
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

---

## 🔐 Authentication Endpoints

### 1. Login
```http
POST /auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": {
    "id": 1,
    "username": "admin",
    "entity_id": 1,
    "mobile_number": "09123456789",
    "is_system_admin": true,
    "is_active": true,
    "is_approved": true
  }
}
```

### 2. Register
```http
POST /auth/register
Content-Type: application/json

{
  "entity_id": 1,
  "username": "newuser",
  "password": "password123",
  "mobile_number": "09123456789",
  "email": "user@example.com"
}
```

### 3. Get Profile
```http
GET /auth/profile
Authorization: Bearer YOUR_TOKEN
```

### 4. Change Password
```http
POST /auth/change-password
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "old_password": "oldpass123",
  "new_password": "newpass123"
}
```

### 5. Logout
```http
POST /auth/logout
Authorization: Bearer YOUR_TOKEN
X-Refresh-Token: YOUR_REFRESH_TOKEN
```

### 6. Approve User (Admin Only)
```http
POST /admin/approve-user
Authorization: Bearer YOUR_ADMIN_TOKEN
Content-Type: application/json

{
  "user_id": 5,
  "approved": true
}
```

---

## 👥 Entity Endpoints

### 1. Create Entity
```http
POST /entities
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "entity_type": "person",
  "code": "PER001",
  "first_name": "احمد",
  "last_name": "محمدی",
  "email": "ahmad@example.com",
  "is_active": true,
  "roles": [1, 2],
  "phones": [
    {
      "phone_number": "09123456789",
      "phone_type": "mobile",
      "is_primary": true
    }
  ],
  "addresses": [
    {
      "address_type": "home",
      "country": "ایران",
      "province": "تهران",
      "city": "تهران",
      "postal_code": "1234567890",
      "address_line": "خیابان ولیعصر، کوچه 10",
      "is_primary": true
    }
  ]
}
```

### 2. Get Entity
```http
GET /entities/{id}
Authorization: Bearer YOUR_TOKEN
```

### 3. Update Entity
```http
PUT /entities/{id}
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "first_name": "محمد",
  "email": "newemail@example.com",
  "is_active": true
}
```

### 4. Delete Entity
```http
DELETE /entities/{id}
Authorization: Bearer YOUR_TOKEN
```

### 5. List Entities
```http
POST /entities/list
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "search": "احمد",
  "entity_type": "person",
  "is_active": true,
  "page": 1,
  "page_size": 20
}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "entity_type": "person",
      "code": "PER001",
      "first_name": "احمد",
      "last_name": "محمدی",
      "email": "ahmad@example.com",
      "is_active": true,
      "roles": [...],
      "phones": [...],
      "addresses": [...],
      "created_at": "2024-01-29T10:00:00Z",
      "updated_at": "2024-01-29T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 50,
    "total_pages": 3
  }
}
```

### 6. Assign Role to Entity
```http
POST /entities/assign-role
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "entity_id": 1,
  "role_id": 2
}
```

### 7. Remove Role from Entity
```http
POST /entities/remove-role
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "entity_id": 1,
  "role_id": 2
}
```

### 8. Add Phone to Entity
```http
POST /entities/{id}/phones
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "phone_number": "09123456789",
  "phone_type": "mobile",
  "is_primary": false
}
```

### 9. Delete Phone from Entity
```http
DELETE /entities/{id}/phones/{phoneId}
Authorization: Bearer YOUR_TOKEN
```

### 10. Add Address to Entity
```http
POST /entities/{id}/addresses
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "address_type": "work",
  "country": "ایران",
  "province": "تهران",
  "city": "تهران",
  "postal_code": "1234567890",
  "address_line": "میدان ونک، برج میلاد",
  "is_primary": false
}
```

### 11. Delete Address from Entity
```http
DELETE /entities/{id}/addresses/{addressId}
Authorization: Bearer YOUR_TOKEN
```

### 12. Get Entities by Role
```http
GET /entities/by-role?roleCode=customer&page=1&pageSize=20
Authorization: Bearer YOUR_TOKEN
```

---

## 📦 Product Endpoints

### 1. Create Product
```http
POST /products
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

# RX Lens Example:
{
  "code": "RX001",
  "name": "E.C.M Bifocal 1.60 Transition Brown SEGMENT-28",
  "product_type": "rx_lens",
  "lens_brand_id": 1,
  "lens_type_id": 2,
  "lens_index_id": 3,
  "lens_material_id": 4,
  "lens_color_id": 5,
  "lens_design_id": 6,
  "base_unit_id": 1,
  "is_active": true
}

# ST Lens Example:
{
  "code": "ST001",
  "name": "SEE CARE 1.60 BLUE HD 2.00 0.00",
  "product_type": "st_lens",
  "lens_brand_id": 1,
  "lens_index_id": 3,
  "lens_coating_id": 2,
  "lens_sph": 2.00,
  "lens_cyl": 0.00,
  "base_unit_id": 1,
  "is_active": true
}

# Service Example:
{
  "code": "SRV001",
  "name": "تراش عدسی",
  "product_type": "service",
  "service_type": "cutting",
  "base_unit_id": 1,
  "is_active": true
}
```

### 2. Get Product
```http
GET /products/{id}
Authorization: Bearer YOUR_TOKEN
```

### 3. Update Product
```http
PUT /products/{id}
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "name": "Updated Product Name",
  "financial_system_code": "FIN001",
  "is_active": true
}
```

### 4. Delete Product
```http
DELETE /products/{id}
Authorization: Bearer YOUR_TOKEN
```

### 5. List Products
```http
POST /products/list
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "search": "1.60",
  "product_type": "rx_lens",
  "lens_brand_id": 1,
  "page": 1,
  "page_size": 20
}
```

### 6. Find RX Product
```http
POST /products/find-rx
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "lens_brand_id": 1,
  "lens_type_id": 2,
  "lens_index_id": 3,
  "lens_material_id": 4,
  "lens_color_id": 5,
  "lens_design_id": 6
}
```

**Response:**
```json
{
  "id": 10,
  "code": "RX001",
  "name": "E.C.M Bifocal 1.60 Transition Brown SEGMENT-28",
  "product_type": "rx_lens",
  "lens_brand": {
    "id": 1,
    "code": "ECM",
    "name": "E.C.M"
  },
  "lens_type": {
    "id": 2,
    "code": "BIFOCAL",
    "name": "Bifocal"
  },
  "is_active": true,
  "created_at": "2024-01-29T10:00:00Z",
  "updated_at": "2024-01-29T10:00:00Z"
}
```

### 7. Find ST Product
```http
POST /products/find-st
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "lens_brand_id": 1,
  "lens_index_id": 3,
  "lens_coating_id": 2,
  "lens_sph": 2.00,
  "lens_cyl": 0.00
}
```

### 8. Find Semi-Finished Product
```http
POST /products/find-semi-finished
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "lens_brand_id": 1,
  "lens_index_id": 3,
  "lens_material_id": 4,
  "lens_color_id": 5,
  "lens_base": 6.5,
  "direction": "left"
}
```

---

## 📊 Response Formats

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {...}
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {...},
  "trace_id": "abc-123-def",
  "timestamp": "2024-01-29T10:00:00Z"
}
```

### Paginated Response
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

---

## 🔥 Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (invalid/missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate entity)
- `500` - Internal Server Error

---

## 🧪 Testing with cURL

### Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Create Entity
```bash
curl -X POST http://localhost:8080/api/v1/entities \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "entity_type": "person",
    "code": "PER001",
    "first_name": "احمد",
    "last_name": "محمدی",
    "is_active": true
  }'
```

### List Products
```bash
curl -X POST http://localhost:8080/api/v1/products/list \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "product_type": "rx_lens",
    "page": 1,
    "page_size": 20
  }'
```

---

## 📌 Notes

1. تمام Dates به فرمت ISO 8601 هستند: `2024-01-29T10:00:00Z`
2. تمام IDs از نوع `int64` هستند
3. فیلدهای با `*` در آخر اختیاری هستند
4. Access Token معتبر برای 15 دقیقه است
5. Refresh Token معتبر برای 7 روز است

---

## 🚀 Next Steps

بعد از اجرای backend:

1. ایجاد Admin User در دیتابیس
2. Login و دریافت Token
3. Test کردن Endpoints با Postman یا cURL
4. ایجاد Entity ها (Customers, Suppliers)
5. ایجاد Products (Lenses, Services)
6. شروع پیاده‌سازی RX/ST Orders

برای سوالات بیشتر، به فایل `QUICKSTART.md` مراجعه کنید.
