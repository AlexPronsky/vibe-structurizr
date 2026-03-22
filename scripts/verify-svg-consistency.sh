#!/usr/bin/env bash
# Verifies consistency between containers and dataflow SVG diagrams.
# The number of arrows (protocols) on containers must match
# the number of unique INF codes on dataflow.
#
# Usage: verify-svg-consistency.sh <containers.svg> <dataflow.svg>

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <containers.svg> <dataflow.svg>" >&2
    exit 1
fi

CONTAINERS_SVG="$1"
DATAFLOW_SVG="$2"

# Count arrows on containers by protocol labels
ARROWS=$(grep -oP '\[(?:REST/HTTPS|MCP/HTTPS|TCP|kafka|HTTPS|AMQP|gRPC)\]' "$CONTAINERS_SVG" | wc -l)

# Count unique INF codes on dataflow
INFS=$(grep -oP 'INF\d+' "$DATAFLOW_SVG" | sort -u)
INF_COUNT=$(echo "$INFS" | wc -l)

echo "=== CONTAINERS: $CONTAINERS_SVG ==="
echo "Arrows (protocols): $ARROWS"
grep -oP '\[(?:REST/HTTPS|MCP/HTTPS|TCP|kafka|HTTPS|AMQP|gRPC)\]' "$CONTAINERS_SVG" | sort | uniq -c
echo ""

echo "=== DATAFLOW: $DATAFLOW_SVG ==="
echo "Unique INFs: $INF_COUNT"
echo "$INFS"
echo ""

if [[ "$ARROWS" -eq "$INF_COUNT" ]]; then
    echo "✓ Consistent: $ARROWS arrows = $INF_COUNT INFs"
    exit 0
else
    echo "✗ NOT consistent: $ARROWS arrows ≠ $INF_COUNT INFs"
    exit 1
fi
