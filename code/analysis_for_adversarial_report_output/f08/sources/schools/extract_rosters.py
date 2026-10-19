import json,re,csv,pathlib
p=pathlib.Path(__file__).resolve().parent
for y in [2019,2020,2021]:
 rows=[]
 for pg in json.load(open(p/f'schools{y}.json')):
  for line in pg['lines']:
   if .39<=line['x']<=.52:
    m=re.match(r'^[|\[\s]*(\d{1,5})(?:\s|$|[|])',line['text'])
    if m and pg['page']>1:
     rows.append(dict(school_year=y,RBD=int(m[1]),page=pg['page'],x=line['x'],y=line['y'],ocr=line['text']))
 with open(p/f'roster_ocr_{y}.csv','w') as f:
  w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
 print(y,len(rows),len(set(r['RBD'] for r in rows)))
