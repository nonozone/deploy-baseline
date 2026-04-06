#!/usr/bin/env bash

compose_prod() {
  docker compose \
    -f "$ROOT_DIR/docker-compose.prod.yml" \
    --env-file "$PROD_ENV_FILE" \
    "$@"
}

wait_for_service_health() {
  local service_name="$1"
  local timeout="${2:-${APP_HEALTHCHECK_TIMEOUT:-120}}"
  local interval="${3:-5}"
  local container_id

  container_id="$(compose_prod ps -q "$service_name")"
  if [[ -z "$container_id" ]]; then
    echo "未找到应用容器：$service_name"
    return 1
  fi

  local deadline=$((SECONDS + timeout))
  while (( SECONDS < deadline )); do
    local health_status
    health_status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$container_id" 2>/dev/null || true)"
    if [[ "$health_status" == "healthy" ]]; then
      echo "应用服务已通过健康检查：$service_name"
      return 0
    fi
    if [[ "$health_status" == "unhealthy" ]]; then
      echo "应用服务健康检查失败：$service_name"
      compose_prod logs --tail=100 "$service_name" || true
      return 1
    fi
    sleep "$interval"
  done

  echo "等待应用服务健康检查超时：$service_name"
  compose_prod logs --tail=100 "$service_name" || true
  return 1
}
