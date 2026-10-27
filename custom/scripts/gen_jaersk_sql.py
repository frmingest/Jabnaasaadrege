#!/usr/bin/env python3
"""Generate insert-only quest text overrides (patch = 10) from custom/jaersk/quests/*.json.

Output (staging, NOT custom/sql until the lint rule is adjusted):
  custom/jaersk/staging/<name>.sql and <name>.rollback.sql
Usage: python custom/scripts/gen_jaersk_sql.py <name> [entry ...]   (no entries = all json files)
Needs custom/scripts/mapping/out/01_schema.tsv and 02_quests_by_npc.tsv (from run-mapping.ps1).
"""
import csv, json, sys, glob, os
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OVERRIDE_PATCH = 10
TEXT = ['Title','Details','Objectives','OfferRewardText','RequestItemsText','EndText',
        'ObjectiveText1','ObjectiveText2','ObjectiveText3','ObjectiveText4']

def columns():
    cols, on = [], False
    for line in open(os.path.join(HERE,'mapping/out/01_schema.tsv'), encoding='utf-8'):
        p = line.rstrip('\n').split('\t')
        if p[0] == 'Field' and not on: on = True; continue
        if on and p[0] == 'Field': break
        if on: cols.append(p[0])
    assert 'patch' in cols and 'Title' in cols, 'schema parse failed'
    return cols

def existing_patches():
    out = {}
    with open(os.path.join(HERE,'mapping/out/02_quests_by_npc.tsv'), encoding='utf-8') as f:
        for r in csv.DictReader(f, delimiter='\t'):
            out[int(r['entry'])] = [int(x) for x in r['patches'].split(',')]
    return out

def lit(s):
    return "'" + s.replace('\\','\\\\').replace("'","\\'").replace('\n','\\n') + "'"

def main():
    name = sys.argv[1]
    want = {int(x) for x in sys.argv[2:]}
    cols, pats = columns(), existing_patches()
    quests = [json.load(open(p, encoding='utf-8')) for p in sorted(glob.glob(os.path.join(ROOT,'jaersk/quests/*.json')))]
    quests = [q for q in quests if not want or q['entry'] in want]
    ids = []
    body = []
    for q in quests:
        e = q['entry']
        if OVERRIDE_PATCH in pats.get(e, []): sys.exit(f'ABORT: quest {e} already has a patch {OVERRIDE_PATCH} row upstream')
        sp = q['source_patch']
        if sp != max(pats[e]): sys.exit(f'ABORT: quest {e} source_patch {sp} is not the effective row {max(pats[e])}')
        sel = []
        for c in cols:
            if c == 'patch': sel.append(str(OVERRIDE_PATCH))
            elif c in q and c in TEXT: sel.append(lit(q[c]))
            else: sel.append(c)
        body.append(f"INSERT INTO quest_template ({', '.join(cols)})\nSELECT {', '.join(sel)}\nFROM quest_template WHERE entry = {e} AND patch = {sp};\n")
        ids.append(e)
    idl = ', '.join(map(str, ids))
    hdr = (f"-- Purpose: Jaersk quest text overrides (insert-only copies with patch = {OVERRIDE_PATCH})\n"
           f"-- Server/Client: server only (text); audio needs client patch\n"
           f"-- Tables: quest_template\n"
           f"-- Id-range: n/a (reuses upstream entry ids {idl}; rows are patch = {OVERRIDE_PATCH}, originals untouched)\n")
    delete = f"DELETE FROM quest_template WHERE entry IN ({idl}) AND patch = {OVERRIDE_PATCH};\n"
    sql = hdr + "START TRANSACTION;\n" + delete + "\n".join(body) + "COMMIT;\n"
    rb = hdr + "START TRANSACTION;\n" + delete + "COMMIT;\n"
    d = os.path.join(ROOT,'jaersk/staging'); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, name+'.sql'),'w',encoding='utf-8',newline='\n').write(sql)
    open(os.path.join(d, name+'.rollback.sql'),'w',encoding='utf-8',newline='\n').write(rb)
    print(f'wrote {name}.sql + rollback for quests: {idl}')
main()
