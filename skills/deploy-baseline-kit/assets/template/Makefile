SHELL := /bin/bash

.PHONY: help setup init local-env-sync prod-env-sync env-sync dev up down logs build test deploy-check deploy rollback prod-up prod-down prod-logs prod-status prod-health prod-version db-up db-down db-shell

BOLD  := \033[1m
RESET := \033[0m

ENV_FILE ?= .env
PROD_ENV_FILE ?= deploy/env/app.prod.env
APP_SERVICE ?= app
DB_SERVICE ?= db
# 允许项目选择开发模式：
# docker = 全部通过 Compose 启动
# mixed  = 只启动 Docker 侧依赖或部分服务，其余服务本地运行
LOCAL_RUNTIME_MODE ?= docker

COMPOSE_BASE = docker compose -f docker-compose.yml --env-file $(ENV_FILE)
COMPOSE_DEV = docker compose -f docker-compose.yml -f docker-compose.dev.yml --env-file $(ENV_FILE)
COMPOSE_PROD = docker compose -f docker-compose.prod.yml --env-file $(PROD_ENV_FILE)

help: ## 显示所有可用命令
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BOLD)%-14s$(RESET) %s\n", $$1, $$2}'

setup: ## 初始化本地开发环境
	bash scripts/setup.sh
	$(MAKE) local-env-sync
	$(MAKE) prod-env-sync

init: setup ## 首次初始化

local-env-sync: ## 非破坏性补齐本地 .env 缺失项
	bash scripts/env-sync-local.sh

prod-env-sync: ## 非破坏性补齐生产 app.prod.env 缺失项
	bash deploy/scripts/env-sync.sh

env-sync: prod-env-sync ## 兼容旧命名，等价于 make prod-env-sync

dev: local-env-sync ## 启动标准开发环境
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

prod-status: ## 查看生产服务状态
	bash deploy/scripts/status.sh

prod-health: ## 检查生产服务健康状态
	bash deploy/scripts/health.sh

prod-version: ## 查看生产服务当前镜像版本
	bash deploy/scripts/version.sh

db-up: ## 启动数据库容器
	$(COMPOSE_BASE) up -d $(DB_SERVICE)

db-down: ## 停止数据库容器
	$(COMPOSE_BASE) stop $(DB_SERVICE)

db-shell: ## 进入数据库容器
	$(COMPOSE_BASE) exec $(DB_SERVICE) sh
