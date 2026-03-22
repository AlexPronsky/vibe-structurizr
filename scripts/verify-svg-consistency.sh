#!/usr/bin/env bash
# Проверяет консистентность между containers и dataflow SVG-диаграммами.
# Количество стрелок (протоколов) на containers должно совпадать
# с количеством уникальных INF-кодов на dataflow.
#
# Usage: verify-svg-consistency.sh <containers.svg> <dataflow.svg>

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <containers.svg> <dataflow.svg>" >&2
    exit 1
fi

CONTAINERS_SVG="$1"
DATAFLOW_SVG="$2"

# Считаем стрелки на containers по меткам протоколов
ARROWS=$(grep -oP '\[(?:REST/HTTPS|MCP/HTTPS|TCP|kafka|HTTPS|AMQP|gRPC)\]' "$CONTAINERS_SVG" | wc -l)

# Считаем уникальные INF-коды на dataflow
INFS=$(grep -oP 'INF\d+' "$DATAFLOW_SVG" | sort -u)
INF_COUNT=$(echo "$INFS" | wc -l)

echo "=== CONTAINERS: $CONTAINERS_SVG ==="
echo "Стрелок (протоколов): $ARROWS"
grep -oP '\[(?:REST/HTTPS|MCP/HTTPS|TCP|kafka|HTTPS|AMQP|gRPC)\]' "$CONTAINERS_SVG" | sort | uniq -c
echo ""

echo "=== DATAFLOW: $DATAFLOW_SVG ==="
echo "Уникальных INF: $INF_COUNT"
echo "$INFS"
echo ""

if [[ "$ARROWS" -eq "$INF_COUNT" ]]; then
    echo "✓ Консистентно: $ARROWS стрелок = $INF_COUNT INF"
    exit 0
else
    echo "✗ НЕ консистентно: $ARROWS стрелок ≠ $INF_COUNT INF"
    exit 1
fi
