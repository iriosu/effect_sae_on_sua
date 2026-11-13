# Issue 23: estimates

Written by R/i2_estimates.R from the frame of R/i1_build.R; how to run and extend: README.md. Exploratory: nothing here is in the paper.

Checks passed before any group was estimated:

- the whole sample reproduces the paper's ten estimates, SEs and Ns, the 112,679 without an offer and the first stage (61.04 pp)
- on the 983 children whose highest-ranked school has no peer measure, the SE equals the HC0 sandwich by hand (0.049026)
- the first-choice estimator reproduces Appendix Table C.4 (16 means, estimates and SEs; N 114,550; 73,314 without an offer; first stage 50.42 (0.27))

School measures (fixed per school before SAE reached it): value added = Table I's estimate (classes of 2013 and 2015), 929 of the 1,020 schools, 173 of them within one SE (sigma_e / sqrt(graduates)) of the median; peer achievement = mean prior-year GPA (SD) of the school's ninth-grade entrants in the classes it selected before SAE (2012 to g-1), 1001 schools. A school is high type above the median over the schools with the measure, each school once. Correlation of the two measures: 0.536 over schools, 0.542 over children. A child's group is set by the highest-ranked over-demanded school among the rows she entered; 821 children entered none (their only over-demanded row is the one SAE added for their current school) and form the group 'current only'.

Differences reported, each with its stars: 190 (part 1: 110; part 2: 40 2SLS and 40 offer-effect differences); 156 of them carry a star. Each ever outcome includes its on-time outcome.

## The whole estimation sample (the paper's Tables IX and X)

2SLS of each outcome on attendance at an over-demanded school, instrumented by an offer at one; the five controls, application-year and chance-group fixed effects. The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values (the paper's lottery convention); * p<0.10, ** p<0.05, *** p<0.01. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, as the notebooks' OLS. Estimation sample 185,970 children; each group is estimated on its own; a 'minus' row's SE is the square root of the sum of the groups' squared SEs (disjoint groups), its p normal; the scores use the children who have each score (N under each block). 'Cells': the chance groups holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
all                            185,970   73,291    101    61.04 (0.24)
```

```
Exam (math-verbal), SD               On time        Ever
all                                  0.023**    0.023***
                                     (0.009)     (0.009)
N                                                       
all                                  113,062     123,108
```

```
NEM, SD                              On time        Ever
all                                -0.173***   -0.175***
                                     (0.008)     (0.008)
N                                                       
all                                  157,648     170,357
```

```
Ranking, SD                          On time        Ever
all                                -0.216***   -0.215***
                                     (0.008)     (0.008)
N                                                       
all                                  157,648     170,357
```

```
Met PACE's grade rule, pp            On time        Ever
all                                 -9.05***    -9.09***
                                      (0.36)      (0.36)
N                                                       
all                                  185,970     185,970
```

```
Met BEA's grade rule, pp             On time        Ever
all                                 -4.79***    -4.93***
                                      (0.26)      (0.26)
N                                                       
all                                  185,970     185,970
```

## Split A: children by the value-added type of the highest-ranked over-demanded school they entered

2SLS of each outcome on attendance at an over-demanded school, instrumented by an offer at one; the five controls, application-year and chance-group fixed effects. The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values (the paper's lottery convention); * p<0.10, ** p<0.05, *** p<0.01. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, as the notebooks' OLS. Estimation sample 185,970 children; each group is estimated on its own; a 'minus' row's SE is the square root of the sum of the groups' squared SEs (disjoint groups), its p normal; the scores use the children who have each score (N under each block). 'Cells': the chance groups holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
high                            66,099   22,266    100    59.97 (0.41)
low                            110,767   48,181    101    61.68 (0.30)
none                             8,283    2,630     99    61.83 (1.20)
current only                       821      214     51    39.59 (4.93)
```

Where the offers and the attendance land (value-added types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
high                           61.2   36.3   38.9 |   54.5   29.5   13.7 |    9.8    5.5   83.7
low                             4.8   94.5   70.8 |    3.9   83.3   12.1 |    1.2   14.4   84.1
none                           17.0   35.8   45.0 |   14.1   30.3   12.6 |    2.7    4.8   85.0
current only                   34.1   59.8    n/a |   21.0   35.5   39.7 |    6.8    7.7   84.5
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ; n/a for 'current only', who entered none) ; the rest of the offers are at over-demanded schools without the measure; (2) among the offered and (3) among the non-offered, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
high                                0.043***     0.035**
                                     (0.015)     (0.015)
low                                    0.003       0.011
                                     (0.012)     (0.011)
none                                 0.105**     0.087**
                                     (0.045)     (0.043)
current only                        -0.513**    -0.493**
                                     (0.255)     (0.239)
high minus low                       0.040**       0.024
                                     (0.019)     (0.019)
N                                                       
high                                  47,625      51,578
low                                   59,313      64,973
none                                   5,545       5,931
current only                             579         626
```

```
NEM, SD                              On time        Ever
high                               -0.216***   -0.220***
                                     (0.014)     (0.014)
low                                -0.148***   -0.149***
                                     (0.010)     (0.010)
none                               -0.180***   -0.182***
                                     (0.042)     (0.040)
current only                          -0.217      -0.238
                                     (0.190)     (0.185)
high minus low                     -0.068***   -0.071***
                                     (0.017)     (0.017)
N                                                       
high                                  58,342      62,226
low                                   91,405      99,728
none                                   7,152       7,618
current only                             749         785
```

```
Ranking, SD                          On time        Ever
high                               -0.265***   -0.267***
                                     (0.014)     (0.014)
low                                -0.186***   -0.185***
                                     (0.011)     (0.010)
none                               -0.234***   -0.234***
                                     (0.042)     (0.041)
current only                          -0.170      -0.184
                                     (0.201)     (0.195)
high minus low                     -0.079***   -0.082***
                                     (0.018)     (0.017)
N                                                       
high                                  58,342      62,226
low                                   91,405      99,728
none                                   7,152       7,618
current only                             749         785
```

```
Met PACE's grade rule, pp            On time        Ever
high                               -12.37***   -12.55***
                                      (0.65)      (0.66)
low                                 -7.19***    -7.11***
                                      (0.43)      (0.44)
none                               -11.64***   -12.44***
                                      (1.88)      (1.90)
current only                            3.05        2.27
                                     (10.87)     (10.85)
high minus low                      -5.18***    -5.44***
                                      (0.78)      (0.79)
N                                                       
high                                  66,099      66,099
low                                  110,767     110,767
none                                   8,283       8,283
current only                             821         821
```

```
Met BEA's grade rule, pp             On time        Ever
high                                -7.02***    -7.26***
                                      (0.49)      (0.49)
low                                 -3.50***    -3.59***
                                      (0.31)      (0.31)
none                                -7.84***    -7.92***
                                      (1.32)      (1.33)
current only                            9.35        9.35
                                      (7.74)      (7.74)
high minus low                      -3.52***    -3.68***
                                      (0.57)      (0.58)
N                                                       
high                                  66,099      66,099
low                                  110,767     110,767
none                                   8,283       8,283
current only                             821         821
```

## Split B: children by the peer-achievement type of that school

2SLS of each outcome on attendance at an over-demanded school, instrumented by an offer at one; the five controls, application-year and chance-group fixed effects. The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values (the paper's lottery convention); * p<0.10, ** p<0.05, *** p<0.01. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, as the notebooks' OLS. Estimation sample 185,970 children; each group is estimated on its own; a 'minus' row's SE is the square root of the sum of the groups' squared SEs (disjoint groups), its p normal; the scores use the children who have each score (N under each block). 'Cells': the chance groups holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
high                           110,230   41,600    101    63.11 (0.30)
low                             73,936   31,174    101    58.05 (0.39)
none                               983      303     64    63.52 (3.51)
current only                       821      214     51    39.59 (4.93)
```

Where the offers and the attendance land (peer-achievement types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
high                           76.5   23.1   52.5 |   69.2   18.5   11.9 |   10.8    4.8   84.2
low                            12.2   87.6   70.5 |   10.0   76.3   13.6 |    2.0   14.3   83.6
none                           24.8   24.4   50.8 |   19.8   22.8   12.9 |    2.9    4.1   87.2
current only                   36.0   63.6    n/a |   20.6   39.7   39.7 |    6.1    9.4   84.5
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ; n/a for 'current only', who entered none) ; the rest of the offers are at over-demanded schools without the measure; (2) among the offered and (3) among the non-offered, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
high                                   0.014       0.016
                                     (0.011)     (0.011)
low                                  0.041**     0.039**
                                     (0.016)     (0.016)
none                                0.358***     0.293**
                                     (0.136)     (0.132)
current only                        -0.513**    -0.493**
                                     (0.255)     (0.239)
high minus low                        -0.026      -0.023
                                     (0.020)     (0.019)
N                                                       
high                                  72,333      78,730
low                                   39,468      43,042
none                                     682         710
current only                             579         626
```

```
NEM, SD                              On time        Ever
high                               -0.198***   -0.196***
                                     (0.010)     (0.010)
low                                -0.124***   -0.133***
                                     (0.014)     (0.014)
none                                -0.289**    -0.269**
                                     (0.134)     (0.129)
current only                          -0.217      -0.238
                                     (0.190)     (0.185)
high minus low                     -0.074***   -0.062***
                                     (0.017)     (0.017)
N                                                       
high                                  95,420     102,702
low                                   60,626      65,978
none                                     853         892
current only                             749         785
```

```
Ranking, SD                          On time        Ever
high                               -0.249***   -0.244***
                                     (0.010)     (0.010)
low                                -0.154***   -0.161***
                                     (0.015)     (0.014)
none                                -0.305**    -0.285**
                                     (0.135)     (0.130)
current only                          -0.170      -0.184
                                     (0.201)     (0.195)
high minus low                     -0.095***   -0.083***
                                     (0.018)     (0.017)
N                                                       
high                                  95,420     102,702
low                                   60,626      65,978
none                                     853         892
current only                             749         785
```

```
Met PACE's grade rule, pp            On time        Ever
high                               -11.35***   -11.43***
                                      (0.46)      (0.46)
low                                 -5.22***    -5.19***
                                      (0.57)      (0.58)
none                                -11.38**      -9.42*
                                      (4.90)      (4.93)
current only                            3.05        2.27
                                     (10.87)     (10.85)
high minus low                      -6.13***    -6.24***
                                      (0.73)      (0.74)
N                                                       
high                                 110,230     110,230
low                                   73,936      73,936
none                                     983         983
current only                             821         821
```

```
Met BEA's grade rule, pp             On time        Ever
high                                -6.15***    -6.32***
                                      (0.33)      (0.34)
low                                 -2.58***    -2.67***
                                      (0.40)      (0.40)
none                                 -7.29**      -6.26*
                                      (3.49)      (3.58)
current only                            9.35        9.35
                                      (7.74)      (7.74)
high minus low                      -3.57***    -3.65***
                                      (0.52)      (0.52)
N                                                       
high                                 110,230     110,230
low                                   73,936      73,936
none                                     983         983
current only                             821         821
```

## Split C: the peer-achievement type of that school, crossed with the child's own 8th-grade GPA (above or at-or-below its median)

2SLS of each outcome on attendance at an over-demanded school, instrumented by an offer at one; the five controls, application-year and chance-group fixed effects. The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values (the paper's lottery convention); * p<0.10, ** p<0.05, *** p<0.01. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, as the notebooks' OLS. Estimation sample 185,970 children; each group is estimated on its own; a 'minus' row's SE is the square root of the sum of the groups' squared SEs (disjoint groups), its p normal; the scores use the children who have each score (N under each block). 'Cells': the chance groups holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
peer high, own high             60,673   23,055    101    60.95 (0.40)
peer high, own low              49,557   18,545    100    65.78 (0.45)
peer low, own high              30,550   12,934    100    55.54 (0.61)
peer low, own low               43,386   18,240    101    59.86 (0.51)
```

Where the offers and the attendance land (peer-achievement types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
peer high, own high            77.6   22.0   50.7 |   71.5   17.6   10.5 |   13.2    5.0   81.4
peer high, own low             75.2   24.6   54.6 |   66.3   19.7   13.8 |    7.8    4.5   87.6
peer low, own high             14.2   85.6   68.4 |   11.8   76.8   11.3 |    2.6   16.8   80.5
peer low, own low              10.8   89.1   71.9 |    8.7   76.0   15.2 |    1.6   12.6   85.8
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ) ; the rest of the offers are at over-demanded schools without the measure; (2) among the offered and (3) among the non-offered, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
peer high, own high                   0.025*     0.030**
                                     (0.015)     (0.014)
peer high, own low                    -0.009      -0.008
                                     (0.016)     (0.016)
peer low, own high                   0.050**     0.061**
                                     (0.024)     (0.024)
peer low, own low                      0.026       0.016
                                     (0.021)     (0.020)
peer high minus low, own high         -0.025      -0.031
                                     (0.028)     (0.028)
peer high minus low, own low          -0.035      -0.024
                                     (0.027)     (0.025)
difference of the two                  0.010      -0.007
                                     (0.039)     (0.038)
N                                                       
peer high, own high                   47,299      49,925
peer high, own low                    25,034      28,805
peer low, own high                    21,087      22,241
peer low, own low                     18,381      20,801
```

```
NEM, SD                              On time        Ever
peer high, own high                -0.218***   -0.220***
                                     (0.013)     (0.013)
peer high, own low                 -0.174***   -0.168***
                                     (0.015)     (0.014)
peer low, own high                 -0.177***   -0.184***
                                     (0.022)     (0.022)
peer low, own low                  -0.087***   -0.100***
                                     (0.018)     (0.017)
peer high minus low, own high         -0.041      -0.036
                                     (0.025)     (0.025)
peer high minus low, own low       -0.087***   -0.067***
                                     (0.024)     (0.023)
difference of the two                  0.046       0.032
                                     (0.035)     (0.034)
N                                                       
peer high, own high                   56,415      58,410
peer high, own low                    39,005      44,292
peer low, own high                    27,814      28,835
peer low, own low                     32,812      37,143
```

```
Ranking, SD                          On time        Ever
peer high, own high                -0.281***   -0.282***
                                     (0.013)     (0.013)
peer high, own low                 -0.208***   -0.199***
                                     (0.015)     (0.014)
peer low, own high                 -0.222***   -0.228***
                                     (0.023)     (0.023)
peer low, own low                  -0.106***   -0.117***
                                     (0.019)     (0.018)
peer high minus low, own high       -0.060**    -0.055**
                                     (0.027)     (0.026)
peer high minus low, own low       -0.103***   -0.082***
                                     (0.024)     (0.023)
difference of the two                  0.043       0.028
                                     (0.036)     (0.035)
N                                                       
peer high, own high                   56,415      58,410
peer high, own low                    39,005      44,292
peer low, own high                    27,814      28,835
peer low, own low                     32,812      37,143
```

```
Met PACE's grade rule, pp            On time        Ever
peer high, own high                -14.90***   -14.94***
                                      (0.73)      (0.73)
peer high, own low                  -7.27***    -7.39***
                                      (0.47)      (0.49)
peer low, own high                  -9.87***   -10.03***
                                      (1.15)      (1.15)
peer low, own low                   -2.55***    -2.41***
                                      (0.53)      (0.56)
peer high minus low, own high       -5.02***    -4.91***
                                      (1.36)      (1.36)
peer high minus low, own low        -4.72***    -4.98***
                                      (0.71)      (0.74)
difference of the two                  -0.30        0.07
                                      (1.53)      (1.55)
N                                                       
peer high, own high                   60,673      60,673
peer high, own low                    49,557      49,557
peer low, own high                    30,550      30,550
peer low, own low                     43,386      43,386
```

```
Met BEA's grade rule, pp             On time        Ever
peer high, own high                 -9.89***   -10.03***
                                      (0.57)      (0.57)
peer high, own low                  -1.88***    -2.10***
                                      (0.24)      (0.25)
peer low, own high                  -6.16***    -6.32***
                                      (0.88)      (0.88)
peer low, own low                     -0.50*      -0.55*
                                      (0.27)      (0.29)
peer high minus low, own high       -3.73***    -3.71***
                                      (1.05)      (1.05)
peer high minus low, own low        -1.38***    -1.55***
                                      (0.36)      (0.38)
difference of the two                -2.35**      -2.16*
                                      (1.11)      (1.12)
N                                                       
peer high, own high                   60,673      60,673
peer high, own low                    49,557      49,557
peer low, own high                    30,550      30,550
peer low, own low                     43,386      43,386
```

## Split D: the value-added type of that school, crossed with its peer-achievement type

2SLS of each outcome on attendance at an over-demanded school, instrumented by an offer at one; the five controls, application-year and chance-group fixed effects. The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values (the paper's lottery convention); * p<0.10, ** p<0.05, *** p<0.01. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, as the notebooks' OLS. Estimation sample 185,970 children; each group is estimated on its own; a 'minus' row's SE is the square root of the sum of the groups' squared SEs (disjoint groups), its p normal; the scores use the children who have each score (N under each block). 'Cells': the chance groups holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
VA high, peer high              54,337   18,665    100    59.90 (0.45)
VA high, peer low               11,762    3,601     96    60.29 (1.02)
VA low, peer high               52,053   21,683    101    65.74 (0.41)
VA low, peer low                58,714   26,498    101    57.89 (0.43)
```

Where the offers and the attendance land (value-added types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
VA high, peer high             61.0   36.4   39.0 |   54.4   29.8   13.4 |    9.8    5.8   83.4
VA high, peer low              62.4   35.5   38.2 |   55.0   28.0   15.3 |    9.8    4.3   85.2
VA low, peer high               5.2   94.0   64.5 |    4.3   84.3   10.7 |    1.3   13.5   84.9
VA low, peer low                4.4   95.0   76.0 |    3.6   82.6   13.3 |    1.1   15.3   83.3
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ) ; the rest of the offers are at over-demanded schools without the measure; (2) among the offered and (3) among the non-offered, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
VA high, peer high                   0.038**      0.030*
                                     (0.016)     (0.016)
VA high, peer low                    0.074**      0.063*
                                     (0.038)     (0.037)
VA low, peer high                     -0.020      -0.007
                                     (0.015)     (0.015)
VA low, peer low                      0.032*      0.033*
                                     (0.018)     (0.017)
VA high minus low, peer high         0.057**      0.038*
                                     (0.022)     (0.022)
VA high minus low, peer low            0.042       0.030
                                     (0.042)     (0.040)
peer high minus low, VA high          -0.036      -0.033
                                     (0.041)     (0.040)
peer high minus low, VA low         -0.051**     -0.041*
                                     (0.023)     (0.023)
N                                                       
VA high, peer high                    39,690      42,936
VA high, peer low                      7,935       8,642
VA low, peer high                     29,855      32,807
VA low, peer low                      29,458      32,166
```

```
NEM, SD                              On time        Ever
VA high, peer high                 -0.221***   -0.225***
                                     (0.015)     (0.015)
VA high, peer low                  -0.183***   -0.191***
                                     (0.035)     (0.034)
VA low, peer high                  -0.176***   -0.169***
                                     (0.014)     (0.013)
VA low, peer low                   -0.114***   -0.124***
                                     (0.016)     (0.015)
VA high minus low, peer high        -0.045**   -0.056***
                                     (0.021)     (0.020)
VA high minus low, peer low          -0.069*     -0.067*
                                     (0.038)     (0.037)
peer high minus low, VA high          -0.038      -0.034
                                     (0.038)     (0.037)
peer high minus low, VA low        -0.062***    -0.046**
                                     (0.021)     (0.020)
N                                                       
VA high, peer high                    48,220      51,349
VA high, peer low                     10,122      10,877
VA low, peer high                     43,812      47,760
VA low, peer low                      47,593      51,968
```

```
Ranking, SD                          On time        Ever
VA high, peer high                 -0.273***   -0.275***
                                     (0.015)     (0.015)
VA high, peer low                  -0.223***   -0.226***
                                     (0.035)     (0.034)
VA low, peer high                  -0.225***   -0.216***
                                     (0.014)     (0.014)
VA low, peer low                   -0.142***   -0.149***
                                     (0.016)     (0.016)
VA high minus low, peer high        -0.048**   -0.059***
                                     (0.021)     (0.020)
VA high minus low, peer low         -0.081**    -0.076**
                                     (0.039)     (0.038)
peer high minus low, VA high          -0.050      -0.049
                                     (0.039)     (0.037)
peer high minus low, VA low        -0.083***   -0.066***
                                     (0.022)     (0.021)
N                                                       
VA high, peer high                    48,220      51,349
VA high, peer low                     10,122      10,877
VA low, peer high                     43,812      47,760
VA low, peer low                      47,593      51,968
```

```
Met PACE's grade rule, pp            On time        Ever
VA high, peer high                 -13.05***   -13.29***
                                      (0.72)      (0.73)
VA high, peer low                   -9.36***    -9.20***
                                      (1.50)      (1.54)
VA low, peer high                   -9.74***    -9.64***
                                      (0.60)      (0.61)
VA low, peer low                    -4.48***    -4.41***
                                      (0.62)      (0.63)
VA high minus low, peer high        -3.31***    -3.65***
                                      (0.94)      (0.95)
VA high minus low, peer low         -4.89***    -4.79***
                                      (1.63)      (1.66)
peer high minus low, VA high         -3.68**     -4.09**
                                      (1.67)      (1.70)
peer high minus low, VA low         -5.26***    -5.24***
                                      (0.86)      (0.88)
N                                                       
VA high, peer high                    54,337      54,337
VA high, peer low                     11,762      11,762
VA low, peer high                     52,053      52,053
VA low, peer low                      58,714      58,714
```

```
Met BEA's grade rule, pp             On time        Ever
VA high, peer high                  -7.46***    -7.80***
                                      (0.54)      (0.55)
VA high, peer low                   -4.92***    -4.72***
                                      (1.06)      (1.09)
VA low, peer high                   -4.79***    -4.83***
                                      (0.43)      (0.43)
VA low, peer low                    -2.11***    -2.26***
                                      (0.43)      (0.44)
VA high minus low, peer high        -2.68***    -2.98***
                                      (0.69)      (0.70)
VA high minus low, peer low          -2.80**     -2.46**
                                      (1.14)      (1.17)
peer high minus low, VA high         -2.54**     -3.09**
                                      (1.19)      (1.22)
peer high minus low, VA low         -2.67***    -2.57***
                                      (0.61)      (0.62)
N                                                       
VA high, peer high                    54,337      54,337
VA high, peer low                     11,762      11,762
VA low, peer high                     52,053      52,053
VA low, peer low                      58,714      58,714
```

## First-choice lotteries: the first-choice children inside the lottery sample

2SLS with a first-choice offer (a main-stage placement at the classroom ranked first) as the instrument and one fixed effect per first-choice lottery, the five controls (no year effects). The 2SLS rows: robust SEs without the N/(N-K) factor, normal p-values. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, K counting the first-choice lotteries. A 'minus' row's SE is the square root of the sum of the two groups' squared SEs. Sample: the first-choice children inside the lottery sample with every control (107,184; the 7,366 outside it with every control have a chance of exactly 1 and no score outcomes in the shared panels). 'Cells': the first-choice lotteries holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
all                            107,184   39,008   2696    53.38 (0.28)
```

Where the offers and the attendance land (value-added types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
all                            19.2   78.0   73.0 |   16.9   71.0    9.7 |    7.8   25.2   65.5
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ) ; the rest of the offers are at over-demanded schools without the measure; (2) among the children with a first-choice offer and (3) among those without one, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
all                                 0.039***    0.035***
                                     (0.012)     (0.012)
N                                                       
all                                   62,172      67,995
```

```
NEM, SD                              On time        Ever
all                                -0.181***   -0.183***
                                     (0.011)     (0.011)
N                                                       
all                                   89,862      97,728
```

```
Ranking, SD                          On time        Ever
all                                -0.225***   -0.226***
                                     (0.011)     (0.011)
N                                                       
all                                   89,862      97,728
```

```
Met PACE's grade rule, pp            On time        Ever
all                                 -9.24***    -9.35***
                                      (0.48)      (0.48)
N                                                       
all                                  107,184     107,184
```

```
Met BEA's grade rule, pp             On time        Ever
all                                 -4.65***    -4.78***
                                      (0.34)      (0.34)
N                                                       
all                                  107,184     107,184
```

## First-choice lotteries, by the value-added type of the first-choice school

2SLS with a first-choice offer (a main-stage placement at the classroom ranked first) as the instrument and one fixed effect per first-choice lottery, the five controls (no year effects). The 2SLS rows: robust SEs without the N/(N-K) factor, normal p-values. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, K counting the first-choice lotteries. A 'minus' row's SE is the square root of the sum of the two groups' squared SEs. Sample: the first-choice children inside the lottery sample with every control (107,184; the 7,366 outside it with every control have a chance of exactly 1 and no score outcomes in the shared panels). 'Cells': the first-choice lotteries holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
high                            28,356    7,263    924    53.59 (0.56)
low                             74,809   30,718   1598    53.45 (0.32)
none                             4,019    1,027    174    50.37 (1.58)
```

Where the offers and the attendance land (value-added types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
high                           72.9   24.9   59.6 |   89.8    0.9    9.2 |   17.8   15.7   64.7
low                             3.0   96.5   77.6 |    0.2   90.0    9.8 |    3.0   30.4   66.0
none                           11.6   24.9   61.2 |    0.4    1.2    9.9 |    8.1   15.6   64.3
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ) ; the rest of the offers are at over-demanded schools without the measure; (2) among the children with a first-choice offer and (3) among those without one, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
high                                0.074***     0.053**
                                     (0.025)     (0.024)
low                                    0.020      0.027*
                                     (0.015)     (0.014)
none                                   0.107       0.042
                                     (0.069)     (0.068)
high minus low                        0.054*       0.026
                                     (0.029)     (0.028)
N                                                       
high                                  20,454      22,216
low                                   39,005      42,863
none                                   2,713       2,916
```

```
NEM, SD                              On time        Ever
high                               -0.300***   -0.297***
                                     (0.023)     (0.022)
low                                -0.146***   -0.151***
                                     (0.013)     (0.013)
none                                 -0.114*     -0.115*
                                     (0.067)     (0.065)
high minus low                     -0.153***   -0.147***
                                     (0.027)     (0.026)
N                                                       
high                                  25,002      26,760
low                                   61,389      67,252
none                                   3,471       3,716
```

```
Ranking, SD                          On time        Ever
high                               -0.371***   -0.364***
                                     (0.023)     (0.022)
low                                -0.180***   -0.183***
                                     (0.013)     (0.013)
none                               -0.205***   -0.201***
                                     (0.069)     (0.066)
high minus low                     -0.191***   -0.180***
                                     (0.027)     (0.026)
N                                                       
high                                  25,002      26,760
low                                   61,389      67,252
none                                   3,471       3,716
```

```
Met PACE's grade rule, pp            On time        Ever
high                               -18.19***   -18.28***
                                      (1.04)      (1.05)
low                                 -6.43***    -6.52***
                                      (0.54)      (0.55)
none                               -12.93***   -13.52***
                                      (3.03)      (3.05)
high minus low                     -11.76***   -11.76***
                                      (1.17)      (1.19)
N                                                       
high                                  28,356      28,356
low                                   74,809      74,809
none                                   4,019       4,019
```

```
Met BEA's grade rule, pp             On time        Ever
high                                -9.88***   -10.20***
                                      (0.76)      (0.77)
low                                 -2.97***    -3.06***
                                      (0.38)      (0.39)
none                                -7.60***    -7.57***
                                      (2.09)      (2.11)
high minus low                      -6.91***    -7.15***
                                      (0.85)      (0.86)
N                                                       
high                                  28,356      28,356
low                                   74,809      74,809
none                                   4,019       4,019
```

## First-choice lotteries, by the peer-achievement type of the first-choice school

2SLS with a first-choice offer (a main-stage placement at the classroom ranked first) as the instrument and one fixed effect per first-choice lottery, the five controls (no year effects). The 2SLS rows: robust SEs without the N/(N-K) factor, normal p-values. The first stage (pp): OLS with robust SEs with the N/(N-K) factor, K counting the first-choice lotteries. A 'minus' row's SE is the square root of the sum of the two groups' squared SEs. Sample: the first-choice children inside the lottery sample with every control (107,184; the 7,366 outside it with every control have a chance of exactly 1 and no score outcomes in the shared panels). 'Cells': the first-choice lotteries holding offered and non-offered children.

```
group                         children  offered  cells  first stage pp
high                            60,474   19,115   1285    55.99 (0.36)
low                             46,174   19,761   1384    50.25 (0.43)
none                               536      132     27    52.63 (4.35)
```

Where the offers and the attendance land (peer-achievement types; shares in %):

```
group                            hi     lo at top | att.hi att.lo  no OD | att.hi att.lo  no OD
high                           82.0   17.7   67.4 |   91.0    0.5    8.4 |   20.4   13.5   65.8
low                             8.5   91.4   79.4 |    0.5   88.7   10.9 |    7.5   27.4   65.0
none                           20.0   20.0   60.0 |    0.8    0.0   12.9 |   11.1   13.9   68.8
```
The three blocks: (1) among the children with any over-demanded offer, the share offered a high-type school (hi), a low-type school (lo), and the highest-ranked over-demanded school the child entered (at top ) ; the rest of the offers are at over-demanded schools without the measure; (2) among the children with a first-choice offer and (3) among those without one, the share attending (in April of the entry year) a high-type over-demanded school (att.hi), a low-type one (att.lo), or no over-demanded school (no OD); the rest attend an over-demanded school without the measure.

```
Exam (math-verbal), SD               On time        Ever
high                                   0.022       0.021
                                     (0.016)     (0.015)
low                                 0.066***    0.061***
                                     (0.020)     (0.020)
none                                   0.113       0.009
                                     (0.201)     (0.206)
high minus low                       -0.044*      -0.040
                                     (0.026)     (0.025)
N                                                       
high                                  38,303      41,866
low                                   23,501      25,740
none                                     368         389
```

```
NEM, SD                              On time        Ever
high                               -0.234***   -0.230***
                                     (0.014)     (0.014)
low                                -0.103***   -0.116***
                                     (0.018)     (0.017)
none                                -0.465**     -0.372*
                                     (0.206)     (0.193)
high minus low                     -0.131***   -0.114***
                                     (0.023)     (0.022)
N                                                       
high                                  51,862      56,152
low                                   37,542      41,090
none                                     458         486
```

```
Ranking, SD                          On time        Ever
high                               -0.297***   -0.289***
                                     (0.014)     (0.014)
low                                -0.122***   -0.135***
                                     (0.019)     (0.018)
none                                -0.480**    -0.384**
                                     (0.208)     (0.196)
high minus low                     -0.175***   -0.154***
                                     (0.024)     (0.023)
N                                                       
high                                  51,862      56,152
low                                   37,542      41,090
none                                     458         486
```

```
Met PACE's grade rule, pp            On time        Ever
high                               -13.99***   -14.06***
                                      (0.63)      (0.64)
low                                 -2.88***    -3.07***
                                      (0.73)      (0.74)
none                                   -9.69       -6.34
                                      (7.46)      (7.53)
high minus low                     -11.11***   -10.99***
                                      (0.96)      (0.98)
N                                                       
high                                  60,474      60,474
low                                   46,174      46,174
none                                     536         536
```

```
Met BEA's grade rule, pp             On time        Ever
high                                -7.29***    -7.38***
                                      (0.45)      (0.46)
low                                  -1.18**    -1.39***
                                      (0.51)      (0.51)
none                                    2.17        4.17
                                      (5.68)      (5.96)
high minus low                      -6.10***    -5.99***
                                      (0.68)      (0.69)
N                                                       
high                                  60,474      60,474
low                                   46,174      46,174
none                                     536         536
```

## Part 2, value-added types: no chance at a school without the measure

2SLS of each outcome on attendance at a high-value-added and at a low-value-added over-demanded school, instrumented by an offer at a school of each type; the five controls and year effects; one fixed effect per pair of cells of the chances at the two types (the paper's hundredths cells; a cell of its own for no chance). The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values. The offer-effect rows, the first stage and its Wald F: OLS with robust SEs with the N/(N-K) factor (K counting the pair-cell fixed effects), t p-values for each offer and normal p-values for their difference, as the notebooks' OLS. Sample: 170,122 children with no positive chance at an over-demanded school without the measure. Left out of the estimation sample of 185,970: 15,848 (15,848 with a positive chance at a school without the measure). Offered a high-type school 14,963, a low-type school 51,721; attending a school without the measure (through a later stage) 478. Children per pair cell: 36.9 (22.2 in the exam sample on time, the thinnest).

```
First stage (pp)                  offer high   offer low
attend high type                       68.36       -1.57
                                      (0.43)      (0.09)
attend low type                        -5.11       63.03
                                      (0.22)      (0.28)
Joint Wald F of the two offers in each first-stage equation (a Sanderson-Windmeijer F is not computed): attend high 13227, attend low 26421; pair cells 4609, varying in the high offer 2307 (59,754 children), in the low offer 2403 (123,039 children); a positive chance at both types 41,386
```

Reading: with effects that differ across children, the two 2SLS coefficients are effects of attending each type only if each offer moves children only between its own type and no over-demanded school; the cross terms of the first stage show, approximately, how far offers move children between the two types. The offer effects compare children within pair cells; with both offers in one regression, each coefficient of these regressions (first stages and offer effects), and so each 2SLS coefficient, can also carry part of the other offer's effect where that effect varies across cells (Goldsmith-Pinkham, Hull and Kolesar 2024).

```
Exam (math-verbal), SD               On time        Ever
2SLS: attend high type              0.044***    0.037***
                                     (0.015)     (0.014)
2SLS: attend low type                  0.009       0.013
                                     (0.010)     (0.010)
2SLS: difference                     0.035**       0.024
                                     (0.016)     (0.016)
Offer effect: high type             0.030***     0.025**
                                     (0.010)     (0.010)
Offer effect: low type                 0.004       0.008
                                     (0.007)     (0.006)
Offer effect: difference             0.025**       0.017
                                     (0.012)     (0.011)
N                                    102,347     111,496
```

```
NEM, SD                              On time        Ever
2SLS: attend high type             -0.231***   -0.228***
                                     (0.014)     (0.013)
2SLS: attend low type              -0.151***   -0.152***
                                     (0.010)     (0.009)
2SLS: difference                   -0.080***   -0.076***
                                     (0.015)     (0.015)
Offer effect: high type            -0.150***   -0.149***
                                     (0.009)     (0.009)
Offer effect: low type             -0.091***   -0.092***
                                     (0.006)     (0.006)
Offer effect: difference           -0.059***   -0.056***
                                     (0.011)     (0.010)
N                                    143,909     155,608
```

```
Ranking, SD                          On time        Ever
2SLS: attend high type             -0.291***   -0.285***
                                     (0.014)     (0.013)
2SLS: attend low type              -0.186***   -0.185***
                                     (0.010)     (0.009)
2SLS: difference                   -0.105***   -0.099***
                                     (0.015)     (0.015)
Offer effect: high type            -0.190***   -0.186***
                                     (0.009)     (0.009)
Offer effect: low type             -0.113***   -0.112***
                                     (0.006)     (0.006)
Offer effect: difference           -0.077***   -0.073***
                                     (0.011)     (0.010)
N                                    143,909     155,608
```

```
Met PACE's grade rule, pp            On time        Ever
2SLS: attend high type             -14.50***   -14.40***
                                      (0.62)      (0.63)
2SLS: attend low type               -6.79***    -6.81***
                                      (0.40)      (0.41)
2SLS: difference                    -7.72***    -7.59***
                                      (0.67)      (0.68)
Offer effect: high type             -9.57***    -9.49***
                                      (0.43)      (0.43)
Offer effect: low type              -4.05***    -4.07***
                                      (0.26)      (0.26)
Offer effect: difference            -5.52***    -5.43***
                                      (0.48)      (0.48)
N                                    170,122     170,122
```

```
Met BEA's grade rule, pp             On time        Ever
2SLS: attend high type              -7.71***    -7.89***
                                      (0.44)      (0.45)
2SLS: attend low type               -3.33***    -3.43***
                                      (0.29)      (0.29)
2SLS: difference                    -4.38***    -4.45***
                                      (0.48)      (0.49)
Offer effect: high type             -5.10***    -5.21***
                                      (0.31)      (0.31)
Offer effect: low type              -1.98***    -2.04***
                                      (0.18)      (0.19)
Offer effect: difference            -3.12***    -3.17***
                                      (0.34)      (0.34)
N                                    170,122     170,122
```

## Part 2, value-added types: no chance at a school without the measure and a positive chance at both types

2SLS of each outcome on attendance at a high-value-added and at a low-value-added over-demanded school, instrumented by an offer at a school of each type; the five controls and year effects; one fixed effect per pair of cells of the chances at the two types (the paper's hundredths cells; a cell of its own for no chance). The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values. The offer-effect rows, the first stage and its Wald F: OLS with robust SEs with the N/(N-K) factor (K counting the pair-cell fixed effects), t p-values for each offer and normal p-values for their difference, as the notebooks' OLS. Sample: 41,386 children with no positive chance at an over-demanded school without the measure and with a positive chance at both types. Left out of the estimation sample of 185,970: 144,584 (15,848 with a positive chance at a school without the measure; 128,736 with a chance at one type only). Offered a high-type school 6,045, a low-type school 14,181; attending a school without the measure (through a later stage) 99. Children per pair cell: 9.4 (6.5 in the exam sample on time, the thinnest).

```
First stage (pp)                  offer high   offer low
attend high type                       70.96       -4.24
                                      (0.65)      (0.30)
attend low type                       -10.90       61.19
                                      (0.51)      (0.56)
Joint Wald F of the two offers in each first-stage equation (a Sanderson-Windmeijer F is not computed): attend high 6767, attend low 7956; pair cells 4407, varying in the high offer 2210 (23,415 children), in the low offer 2302 (30,952 children); a positive chance at both types 41,386
```

Reading: with effects that differ across children, the two 2SLS coefficients are effects of attending each type only if each offer moves children only between its own type and no over-demanded school; the cross terms of the first stage show, approximately, how far offers move children between the two types. The offer effects compare children within pair cells; with both offers in one regression, each coefficient of these regressions (first stages and offer effects), and so each 2SLS coefficient, can also carry part of the other offer's effect where that effect varies across cells (Goldsmith-Pinkham, Hull and Kolesar 2024).

```
Exam (math-verbal), SD               On time        Ever
2SLS: attend high type              0.071***    0.078***
                                     (0.023)     (0.022)
2SLS: attend low type                  0.021       0.026
                                     (0.020)     (0.019)
2SLS: difference                     0.050**     0.052**
                                     (0.022)     (0.022)
Offer effect: high type             0.049***    0.053***
                                     (0.017)     (0.016)
Offer effect: low type                 0.009       0.012
                                     (0.013)     (0.012)
Offer effect: difference             0.039**     0.041**
                                     (0.018)     (0.018)
N                                     28,444      30,945
```

```
NEM, SD                              On time        Ever
2SLS: attend high type             -0.273***   -0.259***
                                     (0.021)     (0.021)
2SLS: attend low type              -0.202***   -0.201***
                                     (0.019)     (0.018)
2SLS: difference                   -0.071***   -0.058***
                                     (0.021)     (0.020)
Offer effect: high type            -0.173***   -0.162***
                                     (0.015)     (0.015)
Offer effect: low type             -0.112***   -0.112***
                                     (0.012)     (0.012)
Offer effect: difference           -0.061***   -0.051***
                                     (0.017)     (0.016)
N                                     36,356      38,960
```

```
Ranking, SD                          On time        Ever
2SLS: attend high type             -0.343***   -0.324***
                                     (0.021)     (0.021)
2SLS: attend low type              -0.234***   -0.232***
                                     (0.019)     (0.019)
2SLS: difference                   -0.109***   -0.093***
                                     (0.021)     (0.020)
Offer effect: high type            -0.219***   -0.206***
                                     (0.015)     (0.015)
Offer effect: low type             -0.128***   -0.128***
                                     (0.012)     (0.012)
Offer effect: difference           -0.090***   -0.078***
                                     (0.017)     (0.016)
N                                     36,356      38,960
```

```
Met PACE's grade rule, pp            On time        Ever
2SLS: attend high type             -17.26***   -16.67***
                                      (0.97)      (0.98)
2SLS: attend low type               -8.13***    -8.23***
                                      (0.86)      (0.87)
2SLS: difference                    -9.13***    -8.44***
                                      (0.94)      (0.96)
Offer effect: high type            -11.36***   -10.93***
                                      (0.69)      (0.70)
Offer effect: low type              -4.24***    -4.33***
                                      (0.54)      (0.54)
Offer effect: difference            -7.12***    -6.61***
                                      (0.74)      (0.76)
N                                     41,386      41,386
```

```
Met BEA's grade rule, pp             On time        Ever
2SLS: attend high type              -8.52***    -8.58***
                                      (0.70)      (0.70)
2SLS: attend low type               -3.77***    -3.96***
                                      (0.64)      (0.65)
2SLS: difference                    -4.75***    -4.63***
                                      (0.67)      (0.68)
Offer effect: high type             -5.63***    -5.66***
                                      (0.49)      (0.50)
Offer effect: low type              -1.95***    -2.06***
                                      (0.40)      (0.41)
Offer effect: difference            -3.69***    -3.60***
                                      (0.53)      (0.53)
N                                     41,386      41,386
```

## Part 2, peer-achievement types: no chance at a school without the measure

2SLS of each outcome on attendance at a high-peer-achievement and at a low-peer-achievement over-demanded school, instrumented by an offer at a school of each type; the five controls and year effects; one fixed effect per pair of cells of the chances at the two types (the paper's hundredths cells; a cell of its own for no chance). The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values. The offer-effect rows, the first stage and its Wald F: OLS with robust SEs with the N/(N-K) factor (K counting the pair-cell fixed effects), t p-values for each offer and normal p-values for their difference, as the notebooks' OLS. Sample: 183,232 children with no positive chance at an over-demanded school without the measure. Left out of the estimation sample of 185,970: 2,738 (2,738 with a positive chance at a school without the measure). Offered a high-type school 35,338, a low-type school 36,832; attending a school without the measure (through a later stage) 214. Children per pair cell: 35.8 (21.7 in the exam sample on time, the thinnest).

```
First stage (pp)                  offer high   offer low
attend high type                       70.12       -2.51
                                      (0.28)      (0.15)
attend low type                        -5.35       60.01
                                      (0.15)      (0.33)
Joint Wald F of the two offers in each first-stage equation (a Sanderson-Windmeijer F is not computed): attend high 33329, attend low 19426; pair cells 5124, varying in the high offer 3258 (115,053 children), in the low offer 3278 (98,405 children); a positive chance at both types 57,967
```

Reading: with effects that differ across children, the two 2SLS coefficients are effects of attending each type only if each offer moves children only between its own type and no over-demanded school; the cross terms of the first stage show, approximately, how far offers move children between the two types. The offer effects compare children within pair cells; with both offers in one regression, each coefficient of these regressions (first stages and offer effects), and so each 2SLS coefficient, can also carry part of the other offer's effect where that effect varies across cells (Goldsmith-Pinkham, Hull and Kolesar 2024).

```
Exam (math-verbal), SD               On time        Ever
2SLS: attend high type                0.018*      0.018*
                                     (0.010)     (0.010)
2SLS: attend low type               0.042***    0.035***
                                     (0.013)     (0.013)
2SLS: difference                     -0.024*      -0.017
                                     (0.014)     (0.013)
Offer effect: high type                0.010       0.010
                                     (0.007)     (0.007)
Offer effect: low type              0.024***    0.020***
                                     (0.008)     (0.008)
Offer effect: difference              -0.014      -0.010
                                     (0.010)     (0.009)
N                                    111,071     121,000
```

```
NEM, SD                              On time        Ever
2SLS: attend high type             -0.198***   -0.196***
                                     (0.009)     (0.009)
2SLS: attend low type              -0.123***   -0.132***
                                     (0.012)     (0.011)
2SLS: difference                   -0.075***   -0.064***
                                     (0.013)     (0.012)
Offer effect: high type            -0.133***   -0.130***
                                     (0.006)     (0.006)
Offer effect: low type             -0.069***   -0.074***
                                     (0.007)     (0.007)
Offer effect: difference           -0.064***   -0.056***
                                     (0.009)     (0.008)
N                                    155,241     167,831
```

```
Ranking, SD                          On time        Ever
2SLS: attend high type             -0.255***   -0.249***
                                     (0.009)     (0.009)
2SLS: attend low type              -0.145***   -0.153***
                                     (0.012)     (0.012)
2SLS: difference                   -0.110***   -0.097***
                                     (0.013)     (0.012)
Offer effect: high type            -0.171***   -0.167***
                                     (0.006)     (0.006)
Offer effect: low type             -0.080***   -0.085***
                                     (0.007)     (0.007)
Offer effect: difference           -0.091***   -0.081***
                                     (0.009)     (0.009)
N                                    155,241     167,831
```

```
Met PACE's grade rule, pp            On time        Ever
2SLS: attend high type             -12.09***   -12.11***
                                      (0.41)      (0.42)
2SLS: attend low type               -4.32***    -4.39***
                                      (0.48)      (0.49)
2SLS: difference                    -7.76***    -7.72***
                                      (0.53)      (0.54)
Offer effect: high type             -8.25***    -8.26***
                                      (0.29)      (0.29)
Offer effect: low type              -2.29***    -2.33***
                                      (0.29)      (0.30)
Offer effect: difference            -5.95***    -5.93***
                                      (0.37)      (0.38)
N                                    183,232     183,232
```

```
Met BEA's grade rule, pp             On time        Ever
2SLS: attend high type              -6.35***    -6.46***
                                      (0.29)      (0.30)
2SLS: attend low type               -2.15***    -2.33***
                                      (0.34)      (0.35)
2SLS: difference                    -4.20***    -4.14***
                                      (0.38)      (0.38)
Offer effect: high type             -4.34***    -4.41***
                                      (0.20)      (0.21)
Offer effect: low type              -1.13***    -1.23***
                                      (0.21)      (0.21)
Offer effect: difference            -3.21***    -3.17***
                                      (0.26)      (0.27)
N                                    183,232     183,232
```

## Part 2, peer-achievement types: no chance at a school without the measure and a positive chance at both types

2SLS of each outcome on attendance at a high-peer-achievement and at a low-peer-achievement over-demanded school, instrumented by an offer at a school of each type; the five controls and year effects; one fixed effect per pair of cells of the chances at the two types (the paper's hundredths cells; a cell of its own for no chance). The 2SLS rows: robust SEs without the N/(N-K) factor and normal p-values. The offer-effect rows, the first stage and its Wald F: OLS with robust SEs with the N/(N-K) factor (K counting the pair-cell fixed effects), t p-values for each offer and normal p-values for their difference, as the notebooks' OLS. Sample: 57,967 children with no positive chance at an over-demanded school without the measure and with a positive chance at both types. Left out of the estimation sample of 185,970: 128,003 (2,738 with a positive chance at a school without the measure; 125,265 with a chance at one type only). Offered a high-type school 13,072, a low-type school 17,655; attending a school without the measure (through a later stage) 34. Children per pair cell: 11.8 (7.4 in the exam sample on time, the thinnest).

```
First stage (pp)                  offer high   offer low
attend high type                       71.75       -3.93
                                      (0.45)      (0.30)
attend low type                       -12.09       58.28
                                      (0.38)      (0.49)
Joint Wald F of the two offers in each first-stage equation (a Sanderson-Windmeijer F is not computed): attend high 14936, attend low 11218; pair cells 4922, varying in the high offer 3159 (43,151 children), in the low offer 3177 (45,373 children); a positive chance at both types 57,967
```

Reading: with effects that differ across children, the two 2SLS coefficients are effects of attending each type only if each offer moves children only between its own type and no over-demanded school; the cross terms of the first stage show, approximately, how far offers move children between the two types. The offer effects compare children within pair cells; with both offers in one regression, each coefficient of these regressions (first stages and offer effects), and so each 2SLS coefficient, can also carry part of the other offer's effect where that effect varies across cells (Goldsmith-Pinkham, Hull and Kolesar 2024).

```
Exam (math-verbal), SD               On time        Ever
2SLS: attend high type                 0.005       0.010
                                     (0.017)     (0.017)
2SLS: attend low type                0.038**      0.034*
                                     (0.019)     (0.019)
2SLS: difference                     -0.033*      -0.024
                                     (0.017)     (0.017)
Offer effect: high type               -0.001       0.003
                                     (0.012)     (0.012)
Offer effect: low type                0.022*      0.019*
                                     (0.012)     (0.011)
Offer effect: difference             -0.023*      -0.016
                                     (0.013)     (0.013)
N                                     36,273      39,633
```

```
NEM, SD                              On time        Ever
2SLS: attend high type             -0.210***   -0.213***
                                     (0.016)     (0.016)
2SLS: attend low type              -0.131***   -0.145***
                                     (0.018)     (0.017)
2SLS: difference                   -0.080***   -0.068***
                                     (0.016)     (0.015)
Offer effect: high type            -0.135***   -0.135***
                                     (0.011)     (0.011)
Offer effect: low type             -0.068***   -0.076***
                                     (0.010)     (0.010)
Offer effect: difference           -0.068***   -0.059***
                                     (0.012)     (0.012)
N                                     49,605      53,669
```

```
Ranking, SD                          On time        Ever
2SLS: attend high type             -0.276***   -0.275***
                                     (0.016)     (0.016)
2SLS: attend low type              -0.154***   -0.168***
                                     (0.018)     (0.018)
2SLS: difference                   -0.122***   -0.107***
                                     (0.016)     (0.015)
Offer effect: high type            -0.179***   -0.176***
                                     (0.011)     (0.011)
Offer effect: low type             -0.079***   -0.086***
                                     (0.011)     (0.010)
Offer effect: difference           -0.101***   -0.090***
                                     (0.012)     (0.012)
N                                     49,605      53,669
```

```
Met PACE's grade rule, pp            On time        Ever
2SLS: attend high type             -13.33***   -13.60***
                                      (0.71)      (0.72)
2SLS: attend low type               -4.79***    -4.89***
                                      (0.78)      (0.79)
2SLS: difference                    -8.54***    -8.71***
                                      (0.68)      (0.69)
Offer effect: high type             -8.99***    -9.17***
                                      (0.48)      (0.49)
Offer effect: low type              -2.27***    -2.32***
                                      (0.46)      (0.47)
Offer effect: difference            -6.72***    -6.85***
                                      (0.52)      (0.53)
N                                     57,967      57,967
```

```
Met BEA's grade rule, pp             On time        Ever
2SLS: attend high type              -6.22***    -6.45***
                                      (0.51)      (0.51)
2SLS: attend low type               -1.85***    -2.07***
                                      (0.57)      (0.58)
2SLS: difference                    -4.37***    -4.38***
                                      (0.48)      (0.49)
Offer effect: high type             -4.24***    -4.38***
                                      (0.34)      (0.35)
Offer effect: low type               -0.83**    -0.95***
                                      (0.34)      (0.34)
Offer effect: difference            -3.41***    -3.43***
                                      (0.37)      (0.37)
N                                     57,967      57,967
```

