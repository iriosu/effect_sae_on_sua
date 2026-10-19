"""Memory-bounded column projection for this project's large XDR RDS data frame.
Called by analysis_for_adversarial_report.Rmd; contains no statistical analysis.
Format reference: https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Serialization-Formats
Only the encountered data-frame/vector types are supported; other types fail.
Columns are selected by a checked index/name manifest because R writes names last.
Output numeric .bin files retain XDR endianness; text missing values use a sentinel.
Requires Python 3 and numpy. No network calls or user-level identifiers are logged.
"""
import gzip,struct,json,sys,pathlib,numpy as np
class Reader:
 def __init__(self,path,out=None,wanted=None):
  self.f=gzip.open(path,'rb'); self.refs=[]; self.out=pathlib.Path(out) if out else None;self.wanted=wanted or {};self.col=None
  assert self.f.read(2)==b'X\n'
  self.version,self.writer,self.minimum=self.ints(3)
  if self.version==3:self.encoding=self.f.read(self.integer()).decode()
  else:assert self.version==2
 def integer(self):return struct.unpack('>i',self.f.read(4))[0]
 def ints(self,n):return struct.unpack('>'+str(n)+'i',self.f.read(4*n))
 def skip(self,n):
  while n:
   b=self.f.read(min(n,8*1024*1024));assert b;n-=len(b)
 def obj(self,top=False,capture=False):
  flag=self.integer();t=flag&255;attr=bool(flag&512);tag=bool(flag&1024)
  if t==255:
   k=flag>>8
   if not k:k=self.integer()
   return self.refs[k-1]
  if t in (0,254,253,252,251):return None
  if t==1:
   v=self.obj();self.refs.append(v);return v
  if t==9:
   n=self.integer();v=None if n==-1 else self.f.read(n).decode('utf-8',errors='strict')
  elif t in (2,6,17):
   a=self.obj() if attr else None;k=self.obj() if tag else None;v=self.obj();tail=self.obj();return {'tag':k,'value':v,'next':tail,'attr':a}
  elif t==22:
   v={};self.refs.append(v);v.update(protected=self.obj(),tag=self.obj())
  elif t in (10,13,14,15,24):
   n=self.integer();assert n>=0
   dtype={10:'>i4',13:'>i4',14:'>f8',15:'>c16',24:'u1'}[t];size=np.dtype(dtype).itemsize*n
   v={'type':t,'n':n,'dtype':dtype}
   if capture and self.col in self.wanted:
    dest=self.out/(self.wanted[self.col]+'.bin');dest.parent.mkdir(exist_ok=True,parents=True)
    with open(dest,'wb') as f:
     remaining=size
     while remaining:
      b=self.f.read(min(remaining,8*1024*1024));assert b;f.write(b);remaining-=len(b)
    v['file']=str(dest)
   elif n<=10000:v['values']=np.frombuffer(self.f.read(size),dtype=dtype).tolist()
   else:self.skip(size)
  elif t in (16,19,20):
   n=self.integer();v=[]
   charout=None
   if t==16 and capture and self.col in self.wanted:
    self.out.mkdir(exist_ok=True,parents=True)
    charout=open(self.out/(self.wanted[self.col]+'.txt'),'w')
   for i in range(n):
    if top:self.col=i
    item=self.obj(capture=top)
    if charout:
     assert item is None or (isinstance(item,str) and '\n' not in item and item!='__RDS_NA__')
     charout.write(('__RDS_NA__' if item is None else item)+'\n')
    if top:
     print('column',i,'type',item.get('type') if isinstance(item,dict) else type(item).__name__,flush=True)
     self.col=None
    if n<=10000 or top:v.append(item)
   if charout:charout.close()
   if n>10000 and not top:v={'type':t,'n':n}
  elif t==238:
   if capture and self.col in self.wanted:raise RuntimeError('Selected ALTREP column needs materialization; projection stopped')
   v={'altrep_info':self.obj(),'state':self.obj(),'attributes':self.obj()};return v
  else:raise RuntimeError(f'unsupported type {t} flag {flag} offset {self.f.tell()} col {self.col}')
  if attr:
   a=self.obj()
   if isinstance(v,dict):v['attributes']=a
   else:v={'value':v,'attributes':a}
  return v
if __name__=='__main__':
 path,out=sys.argv[1:3];wanted={}
 if len(sys.argv)>3:wanted={int(k):v for k,v in json.load(open(sys.argv[3])).items()}
 r=Reader(path,out,wanted);v=r.obj(top=True);assert not r.f.read(1)
 pathlib.Path(out).mkdir(exist_ok=True,parents=True)
 attrs=v['attributes']; actual_names=None
 while attrs:
  if attrs['tag']=='names':actual_names=attrs['value']
  attrs=attrs['next']
 assert actual_names is not None
 for i,name in wanted.items():
  assert actual_names[i]==name, f'Column schema changed at index {i}'
 json.dump(v,open(pathlib.Path(out)/'metadata.json','w'),ensure_ascii=False)
 print('complete',r.f.tell())
