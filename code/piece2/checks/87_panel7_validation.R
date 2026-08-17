# 87_panel7_validation.R -- content validation of Piece 2/lottery_panel_7th.rds
# (7th-grade door), every column against its source, full population, no sampling.
# Clone of 86_panel_validation.R with the door parameters: cod_nivel==7, cohorts
# 2016-2019, college horizon +7, predetermined GPA = 6th grade (gpa_pre_z), take-up
# columns at_y1 + in_any only (entry years 2017-2020, all inside matricula_2011_2023).
# A nonzero count in any check is an error in the panel. Read-only on all inputs.
suppressPackageStartupMessages({library(data.table)}); setDTthreads(4)
t0<-proc.time()
# Paths: run from the Piece 2 folder (or its checks/ subfolder) -- the panel and the
# college outcome table are looked for in the working directory, then one level up,
# then this machine's Dropbox layout. Shared data resolves like the .Rmd files.
home<-ifelse(Sys.getenv("USERPROFILE")!="",Sys.getenv("USERPROFILE"),path.expand("~"))
ROOT<-file.path(home,"Dropbox","Effect of Centralization")
P2<-if(file.exists("lottery_panel_7th.rds")) "." else
    if(file.exists(file.path("..","lottery_panel_7th.rds"))) ".." else
    file.path(ROOT,"Updated Paper Spine","Piece 2")
dp<-function(f){for(p in c(file.path(home,"Dropbox","Effect SAE on SUA","data",f),
                           file.path(ROOT,"code","data",f),
                           file.path(ROOT,"Updated Paper Spine","Piece 1","data",f)))
  if(file.exists(p)) return(p); stop(sprintf("input file not found in any data location: %s",f))}
say<-function(...){cat(sprintf(...),"\n");flush.console()}
ok<-function(lab,n){say("%-64s %s", lab, if(n==0)"0  OK" else sprintf("%d  <-- ERROR",n)); n}
bad<-0L
DOOR<-7L; COHORTS<-2016:2019; HORIZON<-7L; GPA_GRADE<-6L

P<-as.data.table(readRDS(file.path(P2,"lottery_panel_7th.rds")))
CO<-as.data.table(readRDS(file.path(P2,"college_outcomes_2018_2026.rds"))); setkey(CO,mrun,proc)
SAE<-readRDS(dp("sae_admissions.rds"))

say("panel: %s rows | %s lotteries | %d columns", format(nrow(P),big.mark=","),
    format(uniqueN(P$key),big.mark=","), ncol(P))

# ---- schema and internal consistency ----------------------------------------
exp_cols<-c("proc","MRUN","key","RBD","won","PREF","loteria","vintage","rbd_a",
            "test_track","pie_track","tracked","applied","assigned","enrolled",
            "sch_year","prioritario","female","gpa_pre_z","at_y1","in_any",
            "grad_ontime")
bad<-bad+ok("columns missing or unexpected", length(setdiff(exp_cols,names(P)))+length(setdiff(names(P),exp_cols)))
bad<-bad+ok("duplicate (key, MRUN) rows", nrow(P)-uniqueN(P,by=c("key","MRUN")))
bad<-bad+ok("NA in any core column",
  sum(is.na(P$MRUN))+sum(is.na(P$RBD))+sum(is.na(P$won))+sum(is.na(P$PREF))+
  sum(is.na(P$loteria))+sum(is.na(P$proc))+sum(is.na(P$prioritario))+sum(is.na(P$female))+
  sum(is.na(P$applied))+sum(is.na(P$assigned))+sum(is.na(P$enrolled))+sum(is.na(P$tracked))+
  sum(is.na(P$at_y1))+sum(is.na(P$in_any)))
bad<-bad+ok("won outside {0,1} / outcomes outside {0,1}",
  sum(!P$won%in%0:1)+sum(!P$applied%in%0:1)+sum(!P$assigned%in%0:1)+sum(!P$enrolled%in%0:1)+
  sum(!P$tracked%in%0:1)+sum(!P$at_y1%in%0:1)+sum(!P$in_any%in%0:1)+sum(!P$grad_ontime%in%0:1))
bad<-bad+ok("PREF < 1 or loteria <= 0", P[PREF<1L | loteria<=0,.N])
bad<-bad+ok("proc outside 2016-2019", P[!proc%in%COHORTS,.N])
bad<-bad+ok("vintage mislabeled (2016 flag vs proc)", P[(vintage=="2016")!=(proc==2016L),.N])
bad<-bad+ok("sch_year != paste(proc, RBD)", P[sch_year!=paste(proc,RBD),.N])
bad<-bad+ok("key does not start with its own proc", P[substr(key,1,4)!=as.character(proc),.N])
kk<-P[,tstrsplit(key," ")]
bad<-bad+ok("key school does not match RBD column", sum(as.integer(kk$V2)!=P$RBD))
bad<-bad+ok("won=1 but rbd_a missing or != RBD", P[won==1L & (is.na(rbd_a)|rbd_a!=RBD),.N])
bad<-bad+ok("at_y1=1 but in_any=0 (impossible)", P[at_y1==1L & in_any==0L,.N])

# ---- school list: every panel school on Piece 1's 7th-grade list ------------
EC<-as.data.table(readRDS(dp("entrant_composition_panel.rds")))
L7<-unique(EC[cod_nivel==DOOR, rbd]); rm(EC); invisible(gc())
bad<-bad+ok("panel school not on the Piece-1 7th-grade list", P[!RBD%in%L7,.N])

# ---- won / rbd_a against the placement file (full join) ---------------------
D1<-SAE$d1[cod_nivel==DOOR & !is.na(rbd_admitido)]
DA<-unique(D1[,.(proc,MRUN=as.integer(mrun),rbd_p=rbd_admitido,curso_p=cod_curso_admitido)],by=c("proc","MRUN"))
M<-merge(P,DA,by=c("proc","MRUN"),all.x=TRUE)
bad<-bad+ok("rbd_a disagrees with the placement file", M[!is.na(rbd_a)&(is.na(rbd_p)|rbd_p!=rbd_a),.N]+M[is.na(rbd_a)&!is.na(rbd_p),.N])
M[,key_curso:=tstrsplit(key," ",keep=3L)[[1]]]     # NA for the 2-token 2016 keys
bad<-bad+ok("won=1 (2017+) but placed course != key course",
  M[vintage=="std" & won==1L & (is.na(curso_p)|is.na(key_curso)|curso_p!=key_curso),.N])
bad<-bad+ok("won=0 but placement file says placed at that exact classroom",
  M[vintage=="std" & won==0L & !is.na(rbd_p) & rbd_p==RBD & !is.na(curso_p) & !is.na(key_curso) & curso_p==key_curso,.N])
rm(M,D1,DA,kk)

# ---- outcomes against the outcome table (full join, horizon +7) -------------
q<-CO[data.table(mrun=P$MRUN,proc=P$proc+HORIZON),on=.(mrun,proc)]
bad<-bad+ok("tracked flag wrong (row exists vs tracked)", sum(P$tracked!=as.integer(!is.na(q$applied))))
bad<-bad+ok("applied mismatch vs outcome table", sum(P$applied!=fifelse(is.na(q$applied),0L,q$applied)))
bad<-bad+ok("assigned mismatch vs outcome table", sum(P$assigned!=fifelse(is.na(q$assigned),0L,q$assigned)))
bad<-bad+ok("enrolled mismatch vs outcome table", sum(P$enrolled!=fifelse(is.na(q$enrolled),0L,q$enrolled)))
bad<-bad+ok("outcome nonzero while untracked", P[tracked==0L & (applied==1L|assigned==1L|enrolled==1L),.N])
bad<-bad+ok("assigned=1 & applied=0 (impossible)", P[assigned==1L&applied==0L,.N])
rm(q)

# ---- flags against the applicant and application files (full joins) ---------
B<-unique(SAE$b1[,.(proc,MRUN=as.integer(mrun),pB=as.integer(prioritario==1),fB=as.integer(es_mujer==1))],by=c("proc","MRUN"))
M<-merge(P,B,by=c("proc","MRUN"),all.x=TRUE)
bad<-bad+ok("prioritario disagrees with applicant file", M[is.na(pB)|pB!=prioritario,.N])
bad<-bad+ok("female disagrees with applicant file", M[is.na(fB)|fB!=female,.N])
rm(M,B)
nbv<-function(x) !is.na(x)&trimws(as.character(x))!=""&trimws(as.character(x))!="0"
C1<-SAE$c1[cod_nivel==DOOR,.(proc,MRUN=as.integer(mrun),RBD=rbd,PREF=as.integer(preferencia_postulante),
                             tt=nbv(orden_alta_exigencia_transicion),pt=nbv(orden_pie))]
C1<-unique(C1,by=c("proc","MRUN","RBD","PREF"))
M<-merge(P,C1,by=c("proc","MRUN","RBD","PREF"),all.x=TRUE)
bad<-bad+ok("panel row with no matching application row", M[is.na(tt),.N])
bad<-bad+ok("test_track flag disagrees with application file", M[!is.na(tt)&tt!=test_track,.N])
bad<-bad+ok("pie_track flag disagrees with application file", M[!is.na(pt)&pt!=pie_track,.N])
rm(M,C1)

# ---- predetermined GPA against the graded panel (full recomputation) --------
PF<-as.data.table(readRDS(dp("panel_performance_2002_2023.rds")))
G6<-PF[COD_GRADO==GPA_GRADE & COD_ENSE==110L & AGNO%in%COHORTS &
       !is.na(PROM_GRAL) & PROM_GRAL>=1 & PROM_GRAL<=7,.(MRUN,AGNO,PROM_GRAL)]
YM<-c(310L,410L,510L,610L,710L,810L,910L)
G12<-unique(PF[COD_ENSE%in%YM & COD_GRADO==4L & AGNO%in%(COHORTS+HORIZON-1L) & AGNO<=2023L,
               .(MRUN,agno=AGNO,sit=SIT_FIN_R)])
rm(PF); invisible(gc())
G6<-G6[,.(gpa=mean(PROM_GRAL)),by=.(MRUN,AGNO)]
G6[,z:=(gpa-mean(gpa))/sd(gpa),by=AGNO]
xg<-G6[P,on=.(MRUN,AGNO=proc),x.z]
bad<-bad+ok("gpa_pre_z NA-status disagrees with the graded panel", sum(is.na(xg)!=is.na(P$gpa_pre_z)))
bad<-bad+ok("gpa_pre_z value disagrees with the graded panel",
            sum(!is.na(xg)&!is.na(P$gpa_pre_z)&abs(xg-P$gpa_pre_z)>1e-10))
rm(G6,xg); invisible(gc())

# ---- take-up flags against the census (full recomputation) ------------------
MATC<-readRDS(dp("matricula_2011_2023.rds"))
ENT<-unique(MATC[agno%in%(COHORTS+1L),.(agno,MRUN,RBD)])
rm(MATC); invisible(gc())
ee<-data.table(MRUN=P$MRUN,RBD=P$RBD,agno=P$proc+1L)
x1<-as.integer(!is.na(ENT[ee,on=.(MRUN,RBD,agno),which=TRUE]))
bad<-bad+ok("at_y1 disagrees with the census", sum(x1!=P$at_y1))
E2<-unique(ENT[,.(MRUN,agno)])
x3<-as.integer(!is.na(E2[data.table(MRUN=P$MRUN,agno=P$proc+1L),on=.(MRUN,agno),which=TRUE]))
bad<-bad+ok("in_any disagrees with the census", sum(x3!=P$in_any))
rm(ENT,E2,ee,x1,x3); invisible(gc())

# ---- grad-on-time against the school records (full recomputation) -----------
RND<-as.data.table(readRDS(dp("rendimiento_2024_2025.rds")))
G12<-unique(rbind(G12,RND[COD_ENSE%in%YM & COD_GRADO==4L,.(MRUN,agno,sit=SIT_FIN_R)]))
rm(RND); invisible(gc())
GPm<-unique(G12[sit=="P",.(MRUN,agno)])
xgo<-as.integer(!is.na(GPm[data.table(MRUN=P$MRUN,agno=P$proc+HORIZON-1L),on=.(MRUN,agno),which=TRUE]))
bad<-bad+ok("grad_ontime disagrees with the school records", sum(xgo!=P$grad_ontime))
rm(G12,GPm,xgo); invisible(gc())

# ---- frame-level counts against the run log ---------------------------------
say("per-cohort rows/lotteries (compare to the build log):")
print(P[,.(apps=.N,lotteries=uniqueN(key),winners=sum(won)),by=proc][order(proc)])
say("first-choice rows: %s | children in >1 lottery same year (first-choice): %d",
    format(P[PREF==1L,.N],big.mark=","), P[PREF==1L,.(n=uniqueN(key)),by=.(proc,MRUN)][n>1L,.N])

say("")
if(bad==0L) say("PANEL VALIDATION (7TH DOOR): ALL CHECKS 0 -- CLEAN | %.1f min",(proc.time()-t0)[["elapsed"]]/60) else
  say("PANEL VALIDATION (7TH DOOR): %d ERROR CLASSES -- DO NOT SHIP | %.1f min",bad,(proc.time()-t0)[["elapsed"]]/60)
