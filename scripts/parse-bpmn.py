#!/usr/bin/env python3
"""Парсит BPMN 2.0 XML и выводит участников, потоки сообщений и задачи."""

import sys
import xml.etree.ElementTree as ET

NS = '{http://www.omg.org/spec/BPMN/20100524/MODEL}'

TASK_TAGS = {
    'task', 'userTask', 'serviceTask', 'sendTask', 'receiveTask',
    'scriptTask', 'businessRuleTask', 'manualTask', 'subProcess'
}


def parse_bpmn(filepath):
    tree = ET.parse(filepath)
    root = tree.getroot()

    # Participants
    print('=== PARTICIPANTS ===')
    participants = {}
    for p in root.iter(f'{NS}participant'):
        pid = p.get('id')
        name = p.get('name', '(unnamed)')
        process_ref = p.get('processRef', '')
        participants[pid] = name
        print(f'  {pid}: {name} -> {process_ref}')

    # Message flows
    print('\n=== MESSAGE FLOWS ===')
    for mf in root.iter(f'{NS}messageFlow'):
        src = mf.get('sourceRef')
        tgt = mf.get('targetRef')
        src_name = participants.get(src, src)
        tgt_name = participants.get(tgt, tgt)
        print(f'  {src_name} -> {tgt_name}')

    # Tasks in each process
    print('\n=== TASKS/ACTIVITIES ===')
    for proc in root.iter(f'{NS}process'):
        pid = proc.get('id')
        print(f'\nProcess: {pid}')

        # Lanes
        for lane in proc.iter(f'{NS}lane'):
            print(f'  Lane: {lane.get("name", "(unnamed)")}')

        # Tasks
        for elem in proc.iter():
            tag = elem.tag.split('}')[1] if '}' in elem.tag else elem.tag
            if tag in TASK_TAGS:
                name = elem.get('name', '(no name)')
                print(f'  [{tag}] {elem.get("id")}: {name}')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <bpmn-file>', file=sys.stderr)
        sys.exit(1)
    parse_bpmn(sys.argv[1])
