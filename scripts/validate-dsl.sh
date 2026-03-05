#!/usr/bin/env bash
# Валидация Structurizr DSL через API Structurizr Lite
#
# Скрипт вызывает GET /api/workspace/1 с HMAC-авторизацией,
# что принудительно запускает парсинг DSL на сервере.
# Если DSL невалиден, API возвращает ошибку в JSON.
#
# Использование:
#   scripts/validate-dsl.sh
#
# Код возврата: 0 — DSL валиден, 1 — ошибка парсинга

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
NETWORK="ai-arch_default"
STRUCTURIZR_BASE="http://structurizr:8080"

# --- Проверяем, запущен ли Structurizr ---
if ! docker ps --format '{{.Names}}' | grep -q '^structurizr$'; then
  echo "Structurizr не запущен. Запускаю docker compose up -d ..."
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d
  echo "Жду готовности Structurizr (до 30 сек)..."
  for i in $(seq 1 30); do
    if curl -sf "${STRUCTURIZR_BASE}" > /dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

# --- Подключаем dev container к сети Structurizr ---
DEVCONTAINER_ID="$(hostname)"
if ! docker network inspect "${NETWORK}" --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null | grep -q "${DEVCONTAINER_ID}"; then
  docker network connect "${NETWORK}" "${DEVCONTAINER_ID}" 2>/dev/null || true
fi

# --- Перезапускаем, чтобы сбросить кэш DSL ---
echo "Перезапускаю Structurizr для сброса кэша DSL..."
docker compose -f "${PROJECT_DIR}/docker-compose.yml" restart > /dev/null 2>&1

# Ждём полной готовности — /workspace/diagrams должен содержать StructurizrApiClient
PAGE=""
for i in $(seq 1 30); do
  PAGE=$(curl -sf "${STRUCTURIZR_BASE}/workspace/diagrams" 2>/dev/null || true)
  if echo "$PAGE" | grep -q 'StructurizrApiClient'; then
    break
  fi
  PAGE=""
  sleep 1
done

if [ -z "$PAGE" ]; then
  echo "ОШИБКА: Structurizr не отвечает после перезапуска" >&2
  exit 1
fi
API_KEY=$(echo "$PAGE" | grep -A6 'StructurizrApiClient(' | sed -n '4p' | grep -oP '"[^"]*"' | tr -d '"')
API_SECRET=$(echo "$PAGE" | grep -A6 'StructurizrApiClient(' | sed -n '5p' | grep -oP '"[^"]*"' | tr -d '"')

if [ -z "$API_KEY" ] || [ -z "$API_SECRET" ]; then
  echo "ОШИБКА: Не удалось извлечь API-ключи из Structurizr" >&2
  exit 1
fi

# --- Вызываем API с HMAC-авторизацией ---
NONCE=$(date +%s%3N)
CONTENT_MD5="d41d8cd98f00b204e9800998ecf8427e"
CONTENT="GET
/api/workspace/1
${CONTENT_MD5}

${NONCE}
"

HMAC_HEX=$(printf '%s' "$CONTENT" | openssl dgst -sha256 -hmac "$API_SECRET" -hex 2>/dev/null | sed 's/^.* //')
HMAC_B64=$(printf '%s' "$HMAC_HEX" | base64 -w0)
MD5_B64=$(printf '%s' "$CONTENT_MD5" | base64 -w0)

RESPONSE=$(curl -s \
  -H "Content-MD5: ${MD5_B64}" \
  -H "Nonce: ${NONCE}" \
  -H "X-Authorization: ${API_KEY}:${HMAC_B64}" \
  "${STRUCTURIZR_BASE}/api/workspace/1")

# --- Проверяем результат ---
# Успешный ответ содержит JSON с полем "model", ошибка — поле "success":false
if echo "$RESPONSE" | grep -q '"success":false'; then
  # Извлекаем сообщение об ошибке через Python (надёжный парсинг JSON)
  ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message','неизвестная ошибка'))" 2>/dev/null || echo "$RESPONSE")
  echo "ОШИБКА DSL: ${ERROR_MSG}" >&2
  exit 1
fi

if echo "$RESPONSE" | grep -q '"model"'; then
  echo "DSL валиден."
  exit 0
fi

echo "ПРЕДУПРЕЖДЕНИЕ: Неожиданный ответ API. Проверьте вручную." >&2
echo "$RESPONSE" | head -c 500 >&2
exit 1
