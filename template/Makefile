SHELL := /bin/bash

.PHONY: help setup init dev up down logs build test deploy-check deploy rollback prod-up prod-down prod-logs db-up db-down db-shell

BOLD  := \033[1m
RESET := \033[0m

ENV_FILE ?= .env
PROD_ENV_FILE ?= deploy/env/app.prod.env
APP_SERVICE ?= app
DB_SERVICE ?= db

COMPOSE_BASE = docker compose -f docker-compose.yml --env-file $(ENV_FILE)
COMPOSE_DEV = docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file $(ENV_FILE)
COMPOSE_PROD = docker compose -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE)

help: ## 显示所有可用命令
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BOLD)%-14s$(RESET) %s\n", $$1, $$2}'

setup: ## 初始化本地开发环境
	bash scripts/setup.sh

init: setup ## 首次初始化

dev: ## 启动标准开发环境
	bash scripts/dev.sh

up: ## 启动开发态容器
	$(COMPOSE_DEV) up -d --build

down: ## 停止开发态容器
	$(COMPOSE_DEV) down

logs: ## 查看应用日志
	$(COMPOSE_DEV) logs -f $(APP_SERVICE)

build: ## 执行项目构建
	bash scripts/build.sh

test: ## 执行项目测试
	bash scripts/test.sh

deploy-check: ## 执行部署前检查
	bash deploy/scripts/preflight.sh

deploy: ## 执行标准部署
	bash deploy/scripts/deploy.sh

rollback: ## 执行标准回滚
	bash deploy/scripts/rollback.sh

prod-up: deploy ## 兼容旧命名，执行标准部署

prod-down: ## 停止生产容器
	$(COMPOSE_PROD) down

prod-logs: ## 查看生产应用日志
	$(COMPOSE_PROD) logs -f $(APP_SERVICE)

db-up: ## 启动数据库容器
	$(COMPOSE_BASE) up -d $(DB_SERVICE)

db-down: ## 停止数据库容器
	$(COMPOSE_BASE) stop $(DB_SERVICE)

db-shell: ## 进入数据库容器
	$(COMPOSE_BASE) exec $(DB_SERVICE) sh
