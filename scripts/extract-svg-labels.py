#!/usr/bin/env python3
"""Извлекает метки связей из SVG-диаграмм Structurizr.

Для containers SVG — описание + протокол каждой стрелки.
Для dataflow SVG — INF-коды с описаниями.
Автоматически определяет тип диаграммы по содержимому.

Usage:
    python3 scripts/extract-svg-labels.py <svg-file> [<svg-file> ...]
"""

import re
import sys


def extract_texts(svg_content):
    """Извлекает текстовые метки из SVG, объединяя tspan-ы."""
    texts = re.findall(r'<text[^>]*>(.*?)</text>', svg_content)
    results = []
    for t in texts:
        tspans = re.findall(r'<tspan[^>]*>(.*?)</tspan>', t)
        full = ' '.join(
            s.strip() for s in tspans
            if s.strip() and s.strip() != '-'
        )
        if full:
            results.append(full)
    return results


PROTOCOL_RE = re.compile(
    r'^\[(?:REST/HTTPS|MCP/HTTPS|TCP|kafka|HTTPS|AMQP|gRPC)\]$'
)
SKIP_LABELS = {'[Software System]', '[Person]'}


def is_container_label(text):
    return text.startswith('[Container')


def extract_containers_labels(texts):
    """Извлекает пары описание + протокол из containers SVG."""
    arrows = []
    for i, t in enumerate(texts):
        if PROTOCOL_RE.match(t):
            desc = texts[i - 1] if i > 0 else ''
            # Пропускаем системные/контейнерные метки
            if desc in SKIP_LABELS or is_container_label(desc):
                desc = ''
            arrows.append(f'{desc} {t}')
    return arrows


def extract_dataflow_labels(texts):
    """Извлекает INF-метки из dataflow SVG."""
    infs = []
    for t in texts:
        if re.match(r'INF\d+\.', t):
            infs.append(t)
    return sorted(infs, key=lambda x: int(re.search(r'INF(\d+)', x).group(1)))


def process_file(filepath):
    with open(filepath) as f:
        svg = f.read()

    texts = extract_texts(svg)
    is_dataflow = any(re.match(r'INF\d+\.', t) for t in texts)
    is_containers = any(PROTOCOL_RE.match(t) for t in texts)

    print(f'=== {filepath} ===')

    if is_dataflow:
        labels = extract_dataflow_labels(texts)
        print(f'Тип: dataflow ({len(labels)} инфопотоков)\n')
        for label in labels:
            print(f'  {label}')
    elif is_containers:
        labels = extract_containers_labels(texts)
        print(f'Тип: containers ({len(labels)} связей)\n')
        for label in labels:
            print(f'  {label}')
    else:
        print('Тип: не определён (нет INF-меток и протоколов)')

    print()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <svg-file> [<svg-file> ...]',
              file=sys.stderr)
        sys.exit(1)
    for path in sys.argv[1:]:
        process_file(path)
