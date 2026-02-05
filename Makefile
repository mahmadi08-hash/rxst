.PHONY: help run build test clean sqlc deps migrate-up migrate-down docker-up docker-down

help: ## نمایش راهنما
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

deps: ## نصب dependencies
	go mod download
	go mod tidy

sqlc: ## Generate کد از SQL با SQLC
	sqlc generate

run: ## اجرای برنامه
	go run cmd/api/main.go

build: ## Build کردن برنامه
	go build -o bin/api cmd/api/main.go

test: ## اجرای تست‌ها
	go test -v ./...

test-coverage: ## اجرای تست با coverage
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

clean: ## پاک کردن فایل‌های build
	rm -rf bin/
	rm -f coverage.out coverage.html

fmt: ## Format کردن کد
	go fmt ./...
	gofmt -s -w .

lint: ## Lint کردن کد
	golangci-lint run

migrate-create: ## ساخت migration جدید (استفاده: make migrate-create name=create_users_table)
	migrate create -ext sql -dir internal/database/migrations -seq $(name)

migrate-up: ## اجرای migrations
	migrate -path internal/database/migrations -database "postgresql://postgres:postgres@localhost:5432/rxst?sslmode=disable" up

migrate-down: ## برگشت آخرین migration
	migrate -path internal/database/migrations -database "postgresql://postgres:postgres@localhost:5432/rxst?sslmode=disable" down 1

migrate-force: ## Force کردن migration به version خاص
	migrate -path internal/database/migrations -database "postgresql://postgres:postgres@localhost:5432/rxst?sslmode=disable" force $(version)

docker-up: ## راه‌اندازی Docker containers
	docker-compose up -d

docker-down: ## خاموش کردن Docker containers
	docker-compose down

docker-logs: ## نمایش logs
	docker-compose logs -f

seed: ## Seed کردن دیتابیس با داده‌های اولیه
	psql postgresql://postgres:postgres@localhost:5432/rxst < scripts/seed.sql

dev: docker-up deps sqlc run ## راه‌اندازی محیط development

.DEFAULT_GOAL := help
