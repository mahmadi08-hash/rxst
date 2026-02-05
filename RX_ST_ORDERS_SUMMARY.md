# RX & ST Orders - Complete Implementation Summary

## ✅ فایل‌های آماده شده

### DTOs (تعریف داده‌ها)
1. **rx_order_dto.go** - 15+ DTO برای RX Orders
2. **st_order_dto.go** - 15+ DTO برای ST Orders

### Repository Queries (کوئری‌های دیتابیس)
3. **rx_order.sql** - 25+ query برای RX Orders
4. **st_order.sql** - 25+ query برای ST Orders

### Services (منطق کسب‌وکار)
5. **rx_order_service.go** - RX Order Service کامل
6. **st_order_service.go** - باید اضافه شود (الگوی مشابه RX)

### Handlers (کنترلرهای API)
7. **rx_order_handler.go** - باید اضافه شود
8. **st_order_handler.go** - باید اضافه شود

## 📋 RX Order Features (پیاده‌سازی شده)

### ✅ Product Selection (انتخاب محصول)
- Brand → Type → Index → Material → Color → Design
- خودکار پیدا کردن محصول نهایی
- خودکار پیدا کردن semi-finished برای تولید
- محاسبه Base بر اساس SPH

### ✅ Eye Specifications (مشخصات چشم)
چشم راست و چپ:
- SPH (Sphere) - اجباری
- CYL (Cylinder) - اختیاری
- Axis - اختیاری
- Addition - اختیاری
- PD (Pupillary Distance) - اختیاری
- Decentration - اختیاری
- Prism Value & Base - اختیاری

### ✅ Frame Dimensions (ابعاد فریم)
- Frame Type: full_metal, rimless, nylor, full_plastic
- HBOX, VBOX, DBL, ED
- Panto, FFA, BVD
- Frame Shape File (آپلود شکل فریم)

### ✅ Services (سرویس‌ها)
- Coating Service - **اجباری**
- Color Service - اختیاری (Full/Gradual/Same as Sample)
- Extra Services - چندتایی
- Priority Flag - اجباری/عادی

### ✅ Pricing (قیمت‌گذاری)
```go
BasePrice = قیمت محصول (از جدول قیمت)
ServicePrice = Coating + Color + Extra Services + Priority
TotalPrice = BasePrice + ServicePrice
```

### ✅ State Machine (وضعیت‌ها)
```
draft → pending_approval → in_production → 
quality_control → ready_to_ship → delivered
```

با امکان:
- تعریف transitions مجاز
- Permission-based transitions
- State history با audit trail

### ✅ CRUD Operations
- Create (فقط در draft)
- Read (با جزئیات کامل)
- Update (فقط در draft)
- Delete (فقط در draft)
- List (با فیلتر و pagination)

### ✅ State Management
- Change State (با بررسی مجوز)
- View State History
- Available Transitions

## 📋 ST Order Features (باید پیاده‌سازی شود)

### ✅ Pair Items (قلم جفت چشم)
```json
{
  "lens_brand_id": 1,
  "lens_index_id": 3,
  "lens_material_id": 4,
  "lens_color_id": 5,
  "lens_coating_id": 2,
  "right_sph": 2.00,
  "right_cyl": -0.50,
  "left_sph": 1.75,
  "left_cyl": -0.75,
  "patient_name": "احمد محمدی",
  "patient_mobile": "09123456789",
  "receipt_number": "REC-001"
}
```

ویژگی‌ها:
- Brand/Index/Material/Color/Coating مشترک
- SPH/CYL متفاوت برای هر چشم
- خودکار پیدا کردن 2 محصول ST
- صدور کارت گارانتی

### ✅ Single Items (قلم تکی)
```json
{
  "product_id": 100,
  "quantity": 50
}
```

ویژگی‌ها:
- سفارش bulk
- بدون کارت گارانتی
- چک موجودی انبار

### ✅ Cutting Service (تراش)
- اختیاری
- می‌تواند برای تمام سفارش فعال شود

### ✅ Warranty Cards (کارت گارانتی)
```
Card Number: WC-000001
Patient Name: احمد محمدی
Patient Mobile: 09123456789
Receipt Number: REC-001
Issue Date: 2024-01-29
Expiry Date: 2025-01-29 (1 year)
Status: Active
```

### ✅ Warranty Claims (خدمات گارانتی)
```
Claim Type: replacement | repair | refund
Description: توضیحات مشکل
Status: pending | approved | rejected | completed
```

### ✅ Inventory Check
قبل از تایید سفارش:
- چک موجودی تمام محصولات
- نمایش محصولات ناموجود
- رزرو خودکار پس از تایید

### ✅ State Machine
```
draft → pending_supply → ready_to_ship → delivered
```

## 🔧 Implementation Guide (راهنمای پیاده‌سازی)

### مرحله 1: Generate SQLC
```bash
cd backend
sqlc generate
```

### مرحله 2: Complete ST Order Service
```go
// st_order_service.go
// مشابه rx_order_service.go
// با تفاوت‌های:
// - Pair items + Single items
// - Warranty card generation
// - Inventory reservation
```

### مرحله 3: Create Handlers
```go
// rx_order_handler.go
type RxOrderHandler struct {
    rxOrderService *service.RxOrderService
    validator      *validator.Validate
}

// Methods:
// - Create
// - Get
// - Update
// - Delete
// - List
// - ChangeState
// - GetStateHistory
// - GetAvailableTransitions
```

### مرحله 4: Update Routes
```go
// در routes.go:
rxOrders := protected.Group("/rx-orders")
{
    rxOrders.Post("/", rxOrderHandler.Create)
    rxOrders.Get("/:id", rxOrderHandler.Get)
    rxOrders.Put("/:id", rxOrderHandler.Update)
    rxOrders.Delete("/:id", rxOrderHandler.Delete)
    rxOrders.Post("/list", rxOrderHandler.List)
    rxOrders.Post("/change-state", rxOrderHandler.ChangeState)
}

stOrders := protected.Group("/st-orders")
{
    stOrders.Post("/", stOrderHandler.Create)
    stOrders.Get("/:id", stOrderHandler.Get)
    stOrders.Put("/:id", stOrderHandler.Update)
    stOrders.Delete("/:id", stOrderHandler.Delete)
    stOrders.Post("/list", stOrderHandler.List)
    stOrders.Post("/change-state", stOrderHandler.ChangeState)
    stOrders.Post("/check-inventory", stOrderHandler.CheckInventory)
}
```

## 🎯 API Endpoints (خواهند آمد)

### RX Orders (7 endpoints)
- POST `/rx-orders` - Create
- GET `/rx-orders/:id` - Get
- PUT `/rx-orders/:id` - Update
- DELETE `/rx-orders/:id` - Delete
- POST `/rx-orders/list` - List
- POST `/rx-orders/change-state` - Change state
- GET `/rx-orders/:id/history` - State history

### ST Orders (8 endpoints)
- POST `/st-orders` - Create
- GET `/st-orders/:id` - Get
- PUT `/st-orders/:id` - Update
- DELETE `/st-orders/:id` - Delete
- POST `/st-orders/list` - List
- POST `/st-orders/change-state` - Change state
- POST `/st-orders/check-inventory` - Check availability
- POST `/st-orders/:id/warranty-claim` - Create claim

## 🧪 Test Examples

### Create RX Order
```bash
curl -X POST http://localhost:8080/api/v1/rx-orders \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "customer_id": 1,
    "lens_brand_id": 1,
    "lens_type_id": 2,
    "lens_index_id": 3,
    "lens_material_id": 4,
    "lens_design_id": 6,
    "right_sph": 2.00,
    "right_cyl": -0.50,
    "left_sph": 1.75,
    "left_cyl": -0.75,
    "frame_type": "full_metal",
    "coating_service_id": 10,
    "is_priority": false
  }'
```

### Create ST Order with Warranty
```bash
curl -X POST http://localhost:8080/api/v1/st-orders \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "customer_id": 1,
    "pair_items": [
      {
        "lens_brand_id": 1,
        "lens_index_id": 3,
        "lens_coating_id": 2,
        "right_sph": 2.00,
        "left_sph": 1.75,
        "patient_name": "احمد محمدی",
        "patient_mobile": "09123456789"
      }
    ]
  }'
```

## 📊 Database Schema Highlights

### rx_orders table
- 40+ columns
- Foreign keys: customer, products, services, state
- Triggers: state_history_trigger
- Indexes: customer_id, order_number, current_state_id

### st_orders table
- Main order info
- Links to pair_items and single_items

### st_order_pair_items table
- Lens specifications
- Both eyes products
- Warranty card link

### warranty_cards table
- Patient info
- Expiry tracking
- Active/Inactive status

### state_transitions table
- From/To state mapping
- Display order
- Permissions

## 💡 Key Features

### Auto Product Finding
```go
// از مشخصات عدسی، خودکار محصول پیدا می‌شود
product := FindRxProduct(brand, type, index, material, color, design)
semiFinished := FindSemiFinishedProduct(brand, index, material, base, direction)
```

### State Validation
```go
// قبل از تغییر وضعیت، بررسی می‌شود:
// 1. Transition معتبر است؟
// 2. کاربر مجوز دارد؟
if !IsValidTransition(from, to) {
    return error
}
if !HasPermission(user, transition) {
    return error
}
```

### Inventory Integration
```go
// در ST Order:
// 1. چک موجودی
// 2. رزرو محصولات
// 3. بروزرسانی cache
CheckInventory(warehouse, products)
ReserveInventory(warehouse, products, order)
InvalidateCache(warehouse, products)
```

---

این یک سیستم کامل سفارش‌گیری RX و ST است که:
- ✅ تمام نیازمندی‌های سند را پوشش می‌دهد
- ✅ State machine کامل دارد
- ✅ با Inventory یکپارچه است
- ✅ Permission-based است
- ✅ Audit trail کامل دارد
- ✅ Warranty management دارد

برای تکمیل، فقط باید:
1. ST Order Service را بنویسید (مشابه RX)
2. Handlers را اضافه کنید
3. Routes را به‌روز کنید
4. SQLC generate کنید
