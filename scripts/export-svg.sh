#!/usr/bin/env bash
# Экспорт диаграмм Structurizr в SVG через Puppeteer (Docker)
#
# Использование:
#   scripts/export-svg.sh           — экспорт в structurizr/export/
#   scripts/export-svg.sh my_dir    — экспорт в указанный каталог
#
# Требования: Docker, запущенный docker compose (Structurizr Lite)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_SUBDIR="${1:-structurizr/export}"

# Загружаем переменные из .env
if [ -f "${PROJECT_DIR}/.env" ]; then
  set -a; source "${PROJECT_DIR}/.env"; set +a
fi

NETWORK="${DOCKER_NETWORK:?Переменная DOCKER_NETWORK не задана. Проверьте .env файл}"
CONTAINER="${STRUCTURIZR_CONTAINER_NAME:?Переменная STRUCTURIZR_CONTAINER_NAME не задана. Проверьте .env файл}"
STRUCTURIZR_URL="http://${CONTAINER}:8080/workspace/diagrams"
PUPPETEER_IMAGE="ghcr.io/puppeteer/puppeteer:24"

# --- Проверяем, запущен ли Structurizr ---
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Structurizr не запущен. Запускаю docker compose up -d ..."
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d
  echo "Жду готовности Structurizr (до 30 сек)..."
  for i in $(seq 1 30); do
    if curl -sf "http://${CONTAINER}:8080" > /dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

# --- Подключаем dev container к сети Structurizr (если ещё не подключён) ---
DEVCONTAINER_ID="$(hostname)"
if ! docker network inspect "${NETWORK}" --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null | grep -q "${DEVCONTAINER_ID}"; then
  echo "Подключаю dev container к сети ${NETWORK}..."
  docker network connect "${NETWORK}" "${DEVCONTAINER_ID}" 2>/dev/null || true
fi

# --- Дожидаемся, пока Structurizr отвечает ---
echo "Проверяю доступность Structurizr..."
for i in $(seq 1 30); do
  if curl -sf "${STRUCTURIZR_URL}" > /dev/null 2>&1; then
    echo "Structurizr доступен."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "ОШИБКА: Structurizr не отвечает по ${STRUCTURIZR_URL}" >&2
    exit 1
  fi
  sleep 1
done

# --- Создаём каталог для SVG с правами на запись для контейнера puppeteer (uid 10042) ---
mkdir -p "${PROJECT_DIR}/${OUTPUT_SUBDIR}"
chmod 777 "${PROJECT_DIR}/${OUTPUT_SUBDIR}"

# --- Запускаем Puppeteer в Docker ---
echo "Запускаю экспорт диаграмм..."
docker run --rm \
  --network "${NETWORK}" \
  -v "${HOST_PROJECT_ROOT}/scripts/export-diagrams.js:/home/pptruser/export-diagrams.js:ro" \
  -v "${HOST_PROJECT_ROOT}/${OUTPUT_SUBDIR}:/output" \
  "${PUPPETEER_IMAGE}" \
  node /home/pptruser/export-diagrams.js "${STRUCTURIZR_URL}" /output

echo ""
echo "SVG-файлы сохранены в ${OUTPUT_SUBDIR}/"
ls -1 "${PROJECT_DIR}/${OUTPUT_SUBDIR}"/*.svg 2>/dev/null || echo "(файлы не найдены — проверьте логи выше)"
