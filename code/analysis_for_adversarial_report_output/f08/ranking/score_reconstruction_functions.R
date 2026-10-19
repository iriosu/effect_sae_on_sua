# Generated from analysis_for_adversarial_report.Rmd; edit that source chunk.
library(data.table)
setDTthreads(4)
score_round <- function(x,digits=0L) floor(x*10^digits+.5+1e-8)/10^digits
score_trunc <- function(x,digits=0L) floor(x*10^digits+1e-8)/10^digits
nem_from_gpa <- function(gpa,admission_year,group,tables){
  stopifnot(length(gpa)==length(admission_year),length(gpa)==length(group))
  tab<-copy(as.data.table(tables))
  tab[,grade100:=as.integer(score_round(gpa*100))]
  stopifnot(!anyDuplicated(tab,by=c('grad_year','nem_group','grade100')))
  q<-data.table(id=seq_along(gpa),grad_year=admission_year-1L,nem_group=group,
    grade100=as.integer(score_round(gpa*100)))
  as.numeric(tab[q,on=.(grad_year,nem_group,grade100)][order(id),score])
}
nem_from_history <- function(target,tables){
  z<-copy(as.data.table(target))
  z[,gpa_from_history:=score_round(rowMeans(.SD),2L),.SDcols=paste0('gpa_',1:4)]
  z[,nem_history_proxy:=nem_from_gpa(gpa_from_history,grad_year+1L,nem_group,tables)]
  z[complete_history==FALSE,nem_history_proxy:=NA_real_]
  z[,nem_recorded:=fifelse(is.finite(reported_nem)&reported_nem>0,as.numeric(reported_nem),NA_real_)]
  z[,nem_reported_gpa_proxy:=nem_from_gpa(reported_gpa,grad_year+1L,nem_group,tables)]
  z[grad_year %in% 2022:2024 | !between(reported_gpa,4,7),nem_reported_gpa_proxy:=NA_real_]
  z[,nem_proxy:=fcoalesce(nem_reported_gpa_proxy,nem_history_proxy)]
  z[,nem_augmented:=fcoalesce(nem_recorded,nem_proxy)]
  z[,nem_source:=fcase(!is.na(nem_recorded),'Recorded',!is.na(nem_history_proxy),
    'Reconstructed from four passed annual grades',default='Unresolved')]
  z[is.na(nem_recorded) & !is.na(nem_reported_gpa_proxy),
    nem_source:='Converted from recorded two-decimal GPA']
  z[,nem_is_imputed:=is.na(nem_recorded) & !is.na(nem_augmented)]
  z[,nem_unresolved_reason:=fcase(!is.na(nem_augmented),'Available',!complete_history,
    'Incomplete/ambiguous/unordered grade history',default='Unsupported year, modality, or GPA')]
  z
}
ranking_reference_by_context <- function(wide){
  out<-list();k<-0L
  for(first in 1:4) for(last in first:4){
    z<-wide[!is.na(get(paste0('year_',last))) & get(paste0('year_',last))<=2024]
    z[,g_full:=rowMeans(.SD),.SDcols=paste0('gpa_',first:last)]
    z[,chronological:=TRUE]
    if(first<last)for(j in first:(last-1L))
      z[,chronological:=chronological & get(paste0('year_',j))<get(paste0('year_',j+1L))]
    z<-z[is.finite(g_full) & chronological==TRUE]
    z[,`:=`(g_trunc=score_trunc(g_full,2L),g_round=score_round(g_full,2L),
      rbd=get(paste0('rbd_',last)),exit_year=get(paste0('year_',last)),
      teaching=get(paste0('teaching_',last)))]
    z[,same_context:=TRUE]
    for(j in first:last)z[,same_context:=same_context &
      get(paste0('rbd_',j))==rbd & get(paste0('teaching_',j))==teaching]
    for(population in c('exit_context','same_context')){
      q<-if(population=='same_context')z[same_context==TRUE] else z
      k<-k+1L
      out[[k]]<-q[,.(n=.N,sum_trunc=sum(g_trunc),sum_round=sum(g_round),sum_full=sum(g_full),
        max_trunc=max(g_trunc),max_round=max(g_round),max_full=max(g_full)),
        by=.(rbd,teaching,exit_year)]
      out[[k]][,`:=`(first=first,last=last,population=population)]
    }
  }
  rbindlist(out)
}
ranking_student_contexts <- function(target,split_teaching=TRUE){
  out<-list();k<-0L
  for(first in 1:4)for(last in first:4){
    z<-target[complete_history==TRUE]
    same<-rep(TRUE,nrow(z))
    eq<-function(j,h)z[[paste0('rbd_',j)]]==z[[paste0('rbd_',h)]] &
      (!split_teaching | z[[paste0('teaching_',j)]]==z[[paste0('teaching_',h)]])
    for(j in first:last)same<-same & eq(j,first)
    if(first>1L)same<-same & !eq(first-1L,first)
    if(last<4L)same<-same & !eq(last+1L,first)
    z<-z[same]
    z[,g_full:=rowMeans(.SD),.SDcols=paste0('gpa_',first:last)]
    k<-k+1L
    out[[k]]<-z[,.(MRUN,grad_year,rbd=get(paste0('rbd_',last)),
      teaching=get(paste0('teaching_',last)),exit_year=get(paste0('year_',last)),
      first=first,last=last,length=last-first+1L,g_full,g_trunc=score_trunc(g_full,2L),
      g_round=score_round(g_full,2L),nem_group,
      context_group=fifelse(get(paste0('teaching_',last))==310L,'A','C'))]
  }
  ans<-rbindlist(out)
  stopifnot(ans[,all(sum(length)==4L),by=.(MRUN,grad_year)]$V1)
  ans
}
ranking_context_benchmarks <- function(contexts,annual){
  keys<-unique(contexts[,.(rbd,teaching,exit_year,first,last)])
  lagged<-rbindlist(lapply(1:3,function(lag){q<-copy(annual);q[,exit_year:=exit_year+lag];q}))
  sums<-lagged[keys,on=.(rbd,teaching,exit_year,first,last),allow.cartesian=TRUE,nomatch=0][,
    .(reference_n=sum(n),reference_generations=.N,
      h_trunc_raw=sum(sum_trunc)/sum(n),h_round_raw=sum(sum_round)/sum(n),
      h_full_raw=sum(sum_full)/sum(n),h_equal_raw=mean(sum_trunc/n),
      h_equal_round_raw=mean(sum_round/n),
      h_equal_rounded_cohort_raw=mean(score_round(sum_round/n,2L)),
      h_pooled_rounded_cohort_raw=sum(score_round(sum_round/n,2L)*n)/sum(n),
      h_equal_truncated_cohort_raw=mean(score_trunc(sum_round/n,2L)),
      m_trunc_raw=mean(max_trunc),m_round_raw=mean(max_round),m_full_raw=mean(max_full)),
    by=.(rbd,teaching,exit_year,first,last,population)]
  merge(contexts,sums,by=c('rbd','teaching','exit_year','first','last'),all.x=TRUE,
    allow.cartesian=TRUE)
}
ranking_from_contexts <- function(contexts,tables,own='trunc',historical='trunc',
  benchmark_precision='trunc',conversion='context',final_rounding='round',
  population='exit_context',formula='linear_grade',context_rounding='none'){
  selected_population<-population
  z<-copy(contexts[is.na(population)|population==selected_population])
  g<-z[[paste0('g_',own)]]
  h<-z[[paste0('h_',historical,'_raw')]]
  m<-z[[paste0('m_',if(historical=='equal')'trunc' else historical,'_raw')]]
  prec<-if(benchmark_precision=='round')score_round else score_trunc
  h<-prec(h,2L);m<-prec(m,2L)
  group<-if(conversion=='context')z$context_group else z$nem_group
  base<-nem_from_gpa(g,z$grad_year+1L,group,tables)
  hs<-nem_from_gpa(h,z$grad_year+1L,group,tables)
  ms<-nem_from_gpa(m,z$grad_year+1L,group,tables)
  cap<-ifelse(z$grad_year<=2021L,850,1000)
  s<-ifelse(g<=h,base,ifelse(g>=m,cap,hs+(cap-hs)*(g-h)/(m-h)))
  if(formula=='linear_score')s<-ifelse(g<=h,base,ifelse(g>=m,cap,
    hs+(cap-hs)*(base-hs)/(ms-hs)))
  s[is.na(z$reference_n)|z$reference_n<30L|!is.finite(s)|m<=h|
    !z$grad_year %in% tables$grad_year|!group %in% tables$nem_group]<-NA_real_
  if(context_rounding=='round')s<-score_round(s)
  if(context_rounding=='trunc')s<-score_trunc(s)
  z[,context_score:=s]
  a<-z[,.(unrounded=sum(context_score*length)/4,n_contexts=.N,
    min_reference_n=min(reference_n),min_generations=min(reference_generations)),by=.(MRUN,grad_year)]
  a[,ranking_calculated:=if(final_rounding=='trunc')score_trunc(unrounded) else score_round(unrounded)]
  a
}
score_metrics <- function(x){
  x<-x[is.finite(x)]
  if(!length(x))return(list(n=0L,exact=NA_real_,within_1=NA_real_,within_5=NA_real_,
    mae=NA_real_,bias=NA_real_,rmse=NA_real_))
  list(n=length(x),exact=mean(x==0),within_1=mean(abs(x)<=1),within_5=mean(abs(x)<=5),
    mae=mean(abs(x)),bias=mean(x),rmse=sqrt(mean(x^2)))
}
