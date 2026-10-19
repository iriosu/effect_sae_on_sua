# F04.4: entrant counts on the finalized positive-entry composition sample.
# Run from code/: R_LIBS_USER=<did-2.1.2-library> Rscript f04_entrant_counts.R
# Optional SAE_PAPER_ROOT exports the generated table/macros to an existing manuscript.
suppressPackageStartupMessages({library(data.table); library(did); library(knitr)})
stopifnot(getRversion() == '4.5.1', packageVersion('did') == '2.1.2')
setDTthreads(1L)
out <- 'analysis_for_adversarial_report_output/f04'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
run_stamp <- format(Sys.time(), '%Y%m%dT%H%M%S', tz = 'America/Indiana/Indianapolis')
BOOT_DIR <- file.path(out, paste0('bootstrap_', run_stamp))
dir.create(BOOT_DIR)
manifest <- fread('finalized_design_v1/data_manifest.csv')
resolve_input <- function(suffix) {
  m <- manifest[endsWith(path_in_dropbox, suffix)]
  stopifnot(nrow(m) == 1L)
  locations <- c(file.path(path.expand('~/Dropbox'), m$path_in_dropbox),
                 file.path('analysis_for_adversarial_report_output/input', basename(suffix)))
  ok <- locations[file.exists(locations) & file.info(locations)$size > 0]
  if (!length(ok)) stop('Missing input: ', suffix)
  p <- normalizePath(ok[1])
  stopifnot(unname(tools::md5sum(p)) == m$md5, file.info(p)$size == m$bytes)
  p
}
input_files <- c(panel = resolve_input('/section2/section2_panel.rds'),
                intake = resolve_input('/regional/intake_count.rds'),
                headline = resolve_input('/regional/headline.rds'))
reference <- 'finalized_design_v1/section2/section2_cs_did.Rmd'
# Import only these pure function definitions; never evaluate the baseline notebook.
purl_file <- tempfile(fileext = '.R')
invisible(knitr::purl(reference, output = purl_file, documentation = 0, quiet = TRUE))
helpers <- c('with_bootstrap_draws', 'wave_map', 'prep_ri', 'prepare_jackknife', 'score_jackknife')
loaded <- character()
for (expr in parse(purl_file)) {
  if (is.call(expr) && identical(expr[[1]], as.name('<-')) &&
      is.symbol(expr[[2]]) && as.character(expr[[2]]) %in% helpers) {
    eval(expr); loaded <- c(loaded, as.character(expr[[2]]))
  }
}
unlink(purl_file)
stopifnot(setequal(loaded, helpers))
p <- as.data.table(readRDS(input_files['panel']))
stopifnot(!anyDuplicated(p, by = c('MRUN','AGNO')), !anyNA(p$PRIO), all(p$PRIO %in% 0:1))
cells <- p[, .(n_ent = .N, n_low = sum(PRIO == 1L), n_other = sum(PRIO == 0L),
               sh_prio = mean(PRIO)),
           by = .(rbd = RBD, grade = COD_NIVEL, yr = AGNO, region = REGION,
                  door = DOOR, is_entry = IS_ENTRY)]
cells[, `:=`(cell = paste(rbd, grade, sep = '|'), G = door + 1L)]
cells[, cell_id := as.integer(factor(cell))]
stopifnot(uniqueN(cells$cell_id) == 8891L, !anyDuplicated(cells, by = c('cell_id','yr')),
          all(cells$n_ent == cells$n_low + cells$n_other), all(cells$n_ent > 0L))
meta <- unique(cells[, .(cell_id, region, G)])
stopifnot(!anyDuplicated(meta$cell_id))
# Missing cells are unclassified; no operating-grade roster is contained in the input.
grid <- CJ(cell_id = unique(cells$cell_id), yr = sort(unique(cells$yr)))
grid <- merge(grid, cells[, .(cell_id, yr, observed = TRUE)], all.x = TRUE)
audit_year <- grid[, .(possible_cells = .N, observed_positive_entry_cells = sum(!is.na(observed)),
                       unobserved_cells_not_assigned_zero = sum(is.na(observed))), by = yr]
fwrite(audit_year, file.path(out,'sample_coverage.csv'))
fwrite(data.table(metric = c('entrant_records','missing_low_income_flag','nonbinary_flag',
  'school_grade_cells','positive_entry_cell_years','observed_zero_entry_cell_years'),
  value = c(nrow(p),sum(is.na(p$PRIO)),sum(!p$PRIO %in% 0:1),uniqueN(cells$cell_id),nrow(cells),0)),
  file.path(out,'input_audit.csv'))
# Persist only aggregate sample flags, not student identifiers.
fwrite(cells[, .(observed_cells=.N, entrants=sum(n_ent), low_income=sum(n_low), other=sum(n_other)),
             by=.(yr,G,region)], file.path(out,'sample_by_region_cohort.csv'))
rm(p,grid); gc()
ys <- c('n_ent','n_low','n_other','sh_prio')
labels <- c('Total entrants','Low-income entrants','Other entrants','Low-income share (pp)')
fits <- results <- supports <- list()
B_BOOT <- 10000L
for (y in ys) {
  message('Estimating ', y)
  d <- as.data.frame(cells[, .(cell_id, yr, G, region, y=get(y))])
  # Identical seeds give aligned region multipliers across the four outcomes.
  set.seed(20261018L)
  fit_result <- with_bootstrap_draws({
    fit <- did::att_gt(yname='y',tname='yr',idname='cell_id',gname='G',data=d,
      control_group='notyettreated',panel=TRUE,allow_unbalanced_panel=TRUE,
      base_period='universal',anticipation=0L,bstrap=TRUE,biters=B_BOOT,
      clustervars='region',cband=FALSE,print_details=FALSE)
    aggregate <- did::aggte(fit,type='simple',na.rm=TRUE,cband=FALSE)
    list(fit=fit,aggregate=aggregate)
  }, y, sort(unique(d$region)))
  fit <- fit_result$fit; agg <- fit_result$aggregate
  dp <- fit$DIDparams
  mass_data <- if(dp$panel) dp$data[dp$data$yr==min(dp$tlist),] else
    stats::aggregate(dp$data,list(dp$data$cell_id),mean)[,-1]
  k <- which(fit$group<=fit$t & is.finite(fit$att))
  masses <- vapply(fit$group[k],function(g) mean(mass_data$.w*(mass_data$G==g)),numeric(1))
  weights <- masses/sum(masses)
  stopifnot(abs(sum(weights*fit$att[k])-agg$overall.att)<1e-9)
  rows <- lapply(seq_along(k),function(j) {
    i<-k[j];g<-fit$group[i];t<-fit$t[i];b<-g-1L
    tb<-cells[G==g & yr==b];tt<-cells[G==g & yr==t]
    cb<-cells[G>t & yr==b];ct<-cells[G>t & yr==t]
    manual<-mean(tt[[y]])-mean(tb[[y]])-mean(ct[[y]])+mean(cb[[y]])
    stopifnot(abs(manual-fit$att[i])<1e-8)
    data.table(outcome=y,g=g,t=t,weight=weights[j],estimate=fit$att[i],se=fit$se[i],
      n_tb=nrow(tb),n_tt=nrow(tt),n_cb=nrow(cb),n_ct=nrow(ct),
      treated_regions=paste(sort(unique(c(tb$region,tt$region))),collapse=','),
      control_regions=paste(sort(unique(c(cb$region,ct$region))),collapse=','),error=manual-fit$att[i])
  })
  supports[[y]] <- rbindlist(rows)
  fits[[y]] <- list(att=agg$overall.att,se=agg$overall.se,weights=weights,gt=fit$att[k])
  scale <- if(y=='sh_prio')100 else 1
  results[[y]] <- data.table(outcome=y,label=labels[match(y,ys)],
    pre_mean=mean(cells[yr<G][[y]])*scale,estimate=agg$overall.att*scale,se=agg$overall.se*scale,
    lower=(agg$overall.att-qnorm(.975)*agg$overall.se)*scale,
    upper=(agg$overall.att+qnorm(.975)*agg$overall.se)*scale,
    cells=uniqueN(dp$data$cell_id),cell_years=nrow(dp$data),last_post_year=max(fit$t[k]),
    bootstrap_seed=20261018L,bootstrap_draws=B_BOOT)
}
results <- rbindlist(results)
support <- rbindlist(supports)
stopifnot(max(abs(fits$n_ent$gt-fits$n_low$gt-fits$n_other$gt))<1e-8,
  abs(fits$n_ent$att-fits$n_low$att-fits$n_other$att)<1e-8,
  identical(fits$n_ent$weights,fits$n_low$weights),identical(fits$n_ent$weights,fits$n_other$weights),
  identical(fits$n_ent$weights,fits$sh_prio$weights), all(is.finite(results$se)))
fwrite(support,file.path(out,'group_time_support.csv'))
# Fast, exact sufficient-statistic implementation of the baseline paired RI estimator.
# Region-by-entry-group sums preserve paired cell membership under every reassignment.
wv <- wave_map(cells)
saved <- lapply(input_files[c('intake','headline')],readRDS)
stopifnot(identical(saved$intake$observed,wv),identical(saved$headline$observed,wv))
W <- rbind(unname(wv),saved$intake$assignments,saved$headline$assignments)
R <- length(wv); B <- nrow(W); J <- R+1L
sums_num <- array(0,c(B,J,length(ys))); sums_den <- matrix(0,B,J)
pps <- lapply(ys,function(y)prep_ri(cells,y));names(pps)<-ys
prepared <- prepare_jackknife(pps[[1]],wv)
for (pair in prepared$pairs) {
  g<-pair$g;t<-pair$t
  nt<-nc<-matrix(0,B,R);st<-sc<-lapply(ys,function(y)matrix(0,B,R))
  for(e in unique(pps[[1]]$is_entry)) {
    idx<-pair$rows[pps[[1]]$is_entry[pair$rows]==e]
    if(!length(idx))next
    ri<-match(as.character(pps[[1]]$region[idx]),names(wv))
    cnt<-tabulate(ri,nbins=R)
    GG<-W+2L-e
    tm<-GG==g;cm<-GG>t
    nt<-nt+sweep(tm,2,cnt,'*');nc<-nc+sweep(cm,2,cnt,'*')
    for(q in seq_along(ys)) {
      delta<-pps[[q]]$M[idx,match(t,pps[[q]]$yrs)]-pps[[q]]$M[idx,match(g-1L,pps[[q]]$yrs)]
      z<-numeric(R);s<-tapply(delta,ri,sum);z[as.integer(names(s))]<-s
      st[[q]]<-st[[q]]+sweep(tm,2,z,'*');sc[[q]]<-sc[[q]]+sweep(cm,2,z,'*')
    }
  }
  leave<-function(x)cbind(rowSums(x),rowSums(x)-x)
  ntj<-leave(nt);ncj<-leave(nc);valid<-ntj>0 & ncj>0
  sums_den<-sums_den+ifelse(valid,ntj,0)
  for(q in seq_along(ys)) {
    effect<-leave(st[[q]])/ntj-leave(sc[[q]])/ncj
    sums_num[,,q]<-sums_num[,,q]+ifelse(valid,effect*ntj,0)
  }
}
ri_all <- list();ri_summary<-list()
for(q in seq_along(ys)) {
  est<-sums_num[,,q]/sums_den
  jkse<-sqrt((R-1)/R*rowSums((est[,-1,drop=FALSE]-rowMeans(est[,-1,drop=FALSE]))^2))
  stat<-est[,1]/jkse
  # Compare optimized results with untouched baseline helper, observed + six schedules.
  pp<-prepare_jackknife(pps[[q]],wv)
  check_ids<-c(1L,2:4,3001:3003)
  for(b in check_ids) {
    check<-score_jackknife(pp,setNames(W[b,],names(wv)))
    stopifnot(max(abs(check-c(est[b,1],stat[b])),na.rm=TRUE)<1e-8)
  }
  take<-if(ys[q]=='sh_prio') seq.int(3001L,nrow(W)) else 2:3000
  finite<-is.finite(stat[take]);stopifnot(mean(!finite)<=.05)
  pval<-(1+sum(abs(stat[take][finite])>=abs(stat[1])))/(1+sum(finite))
  scale<-if(ys[q]=='sh_prio')100 else 1
  ri_summary[[q]]<-data.table(outcome=ys[q],paired_estimate=est[1,1]*scale,
    paired_jackknife_se=jkse[1]*scale,ri_statistic=stat[1],p_ri=pval,
    permutation_draws=length(take),invalid_permutations=sum(!finite),
    schedule=if(ys[q]=='sh_prio')'headline.rds' else 'intake_count.rds')
  ri_all[[q]]<-data.table(outcome=ys[q],draw=c(0L,seq_along(take)),
    estimate=est[c(1,take),1]*scale,statistic=stat[c(1,take)])
}
ri_summary<-rbindlist(ri_summary)
results<-merge(results,ri_summary,by='outcome',sort=FALSE)
results<-results[match(ys,outcome)]
fwrite(results,file.path(out,'effects.csv'))
fwrite(rbindlist(ri_all),file.path(out,'permutation_statistics.csv'))
# Across-outcome covariance from aligned aggregate bootstrap deviations, unscaled units.
draws<-lapply(ys,function(y)readRDS(file.path(BOOT_DIR,paste0(y,'_02.rds'))))
stopifnot(all(vapply(draws,function(z)identical(z$multipliers,draws[[1]]$multipliers),logical(1))))
bootdev<-do.call(cbind,lapply(draws,function(z)as.vector(z$deviations)));colnames(bootdev)<-ys
stopifnot(max(abs(bootdev[,1]-bootdev[,2]-bootdev[,3]))<1e-8)
fwrite(data.table(outcome=ys,stats::cov(bootdev)),file.path(out,'bootstrap_covariance.csv'))
# did reports IQR-scaled multiplier SEs; covariance above uses sample second moments.
checks<-data.table(check=c('count_ATT_additivity','count_group_time_additivity','bootstrap_draw_additivity',
                          'published_share_point_estimate','published_total_count_point_estimate'),
 error=c(fits$n_ent$att-fits$n_low$att-fits$n_other$att,
         max(abs(fits$n_ent$gt-fits$n_low$gt-fits$n_other$gt)),
         max(abs(bootdev[,1]-bootdev[,2]-bootdev[,3])),round(fits$sh_prio$att,3)-.035,round(fits$n_ent$att,3)+.398))
stopifnot(all(abs(checks$error)<1e-8))
fwrite(checks,file.path(out,'verification.csv'))
fwrite(data.table(item=c(names(input_files),'reference_notebook','analysis_script'),
  path=c(input_files,reference,'f04_entrant_counts.R'),
  md5=unname(tools::md5sum(c(input_files,reference,'f04_entrant_counts.R')))),file.path(out,'provenance.csv'))
writeLines(c(paste('Run:',run_stamp),paste('Bootstrap archive:',BOOT_DIR),capture.output(sessionInfo())),
           file.path(out,'session_info.txt'))
print(results)
# Generate manuscript artifacts using only computed results.
f<-function(x)sprintf('%.2f',x)
macro<-function(name,value)paste0('\\newcommand{\\',name,'}{',value,'}')
macros<-c(macro('CountLowATT',f(results[outcome=='n_low',estimate])),
 macro('CountLowLower',f(results[outcome=='n_low',lower])),macro('CountLowUpper',f(results[outcome=='n_low',upper])),
 macro('CountOtherATT',f(results[outcome=='n_other',estimate])),macro('CountOtherAbsATT',f(abs(results[outcome=='n_other',estimate]))),
 macro('CountOtherLower',f(results[outcome=='n_other',lower])),macro('CountOtherUpper',f(results[outcome=='n_other',upper])),
 macro('CountTotalATT',f(results[outcome=='n_ent',estimate])),macro('CountTotalAbsATT',f(abs(results[outcome=='n_ent',estimate]))))
writeLines(macros,file.path(out,'entrant_count_macros.tex'))
body<-vapply(seq_len(nrow(results)),function(i) {
 r<-results[i];paste0(r$label,' & ',f(r$pre_mean),' & $',f(r$estimate),'$ & ',f(r$se),
 ' & $[',f(r$lower),', ',f(r$upper),']$ \\\\')
},character(1))
paired_body<-vapply(seq_len(nrow(results)),function(i) {
 r<-results[i];pv<-if(r$p_ri<.001)'$<0.001$' else sprintf('%.3f',r$p_ri)
 paste0(r$label,' & & $',f(r$paired_estimate),'$ & ',f(r$paired_jackknife_se),' & ',pv,' \\\\')
},character(1))
table<-c('\\begin{table}[!htbp]','\\singlespacing\\renewcommand{\\arraystretch}{1.2}',
 '\\centering','\\caption{Entrant Counts and Low-Income Composition}',
 '\\label{tab: entrant counts}','\\small','\\setlength{\\tabcolsep}{4pt}',
 '\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}lrrrr@{}}','\\toprule',
 '\\multicolumn{5}{l}{\\textit{Panel A. Unbalanced-panel estimates}} \\\\[3pt]',
 'Outcome & \\makecell{Pre-adoption\\\\mean} & Effect & SE & 95\\% CI \\\\',
 '\\midrule',body,'\\addlinespace[9pt]',
 '\\multicolumn{5}{l}{\\textit{Panel B. Paired estimates and regional permutation tests}} \\\\[3pt]',
 'Outcome & & Effect & \\makecell{Jackknife\\\\SE} & \\makecell{Permutation\\\\$p$-value} \\\\',
 '\\midrule',paired_body,'\\bottomrule','\\end{tabular*}','\\par\\smallskip',
 '\\begin{minipage}{\\textwidth}\\footnotesize',
 paste0('Notes: Counts are entrants per school-grade-year; shares are in percentage points. ',
 'Low-income status is the entry-year \\emph{prioritario} flag; other entrants are those not flagged. ',
 'Panel A uses the common positive-entry sample and adoption-group weights of the main composition design (',
 format(results$cells[1],big.mark=','),' school-grades and ',format(results$cell_years[1],big.mark=','),' cell-years). ',
 'Unobserved school-grade-years are not assigned zero entrants. Pre-adoption means average observed cell-years before adoption. ',
 'The group-time estimates use not-yet-treated comparisons and a universal $g-1$ base, ',
 'covering supported entering classes in 2017--2020. Panel A SE use 10,000 region-clustered multiplier-bootstrap draws; ',
 'intervals are pointwise normal intervals using those SE. Panel B restricts each comparison to cells observed in both years ',
 'and weights contrasts by their paired treated-cell counts. It reports delete-one-region jackknife SE and ',
 'studentized permutation tests using 2,999 regional reassignments for counts and 9,999 for the share. ',
 'These tests concern Panel B estimates; see Appendix~\\ref{app: regional inference}. ',
 'Neither procedure resolves the few-region inference concerns. The estimates do not measure subgroup admission probabilities or national entrant totals.'),
 '\\end{minipage}','\\end{table}')
writeLines(table,file.path(out,'appendix_entrant_counts.tex'))
paper<-Sys.getenv('SAE_PAPER_ROOT')
if(nzchar(paper)) {
 stopifnot(dir.exists(file.path(paper,'tables')))
 for(n in c('appendix_entrant_counts.tex','entrant_count_macros.tex'))
   stopifnot(file.copy(file.path(out,n),file.path(paper,'tables',n),overwrite=TRUE))
}
