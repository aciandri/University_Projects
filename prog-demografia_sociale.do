use "/Users/aurora/Desktop/progetto_demo_soc/DATI EVS/EVS data 1981-2008.dta", clear
*ssc install fre, replace
* DATE: September 2020

/* Codings of missing values:
-5             .A             other missing
-4             .B             question not asked
-3             .C             not applicable
-2             .D             no answer
-1             .E             don't know
*/

**************************
**Selezione del campione**
**************************


tab x001,m
rename x001 gender
keep if gender==2
tab gender,m

tab x003,m
rename x003 age
keep if age>=40 & age<=75
tab age,m

**********************************
**Variabile dipendente: n. figli**
**********************************
tab x011_01,m
tab u001a,m
tab x011,m
gen fv=x011_01
*figli vivi

replace x011_01=x011_01+1 if u001a==1
tab x011_01,m
tab fv x011_01,m
*prova

gen nfigli=x011_01
replace nfigli=0 if x011==0 
replace nfigli=1 if x011==1 
replace nfigli=2 if x011==2 
replace nfigli=3 if x011==3 
replace nfigli=4 if x011==4 
replace nfigli=5 if x011==5 
replace nfigli=6 if x011==6 
replace nfigli=7 if x011==7 
replace nfigli=8 if x011==8 


tab nfigli x011,m
tab nfigli x011_01,m

drop if nfigli>=.
label variable nfigli "How many children"
label value nfigli nfigli
tab nfigli

**************************************
**Variabile indipendente: istruzione**
**************************************

*tab x025a,m
tab x023,m
rename x023 eduy 
drop if eduy>age | eduy>40 | eduy<6 & eduy>0

*gen edulvl=.
*replace edulvl=1 if eduy<14 & s002evs<4
*replace edulvl=2 if eduy>13 & eduy<17 & s002evs<4
*replace edulvl=3 if eduy>16 & eduy<21 & s002evs<4
*replace edulvl=4 if eduy>20 & eduy<17 & s002evs<4

*replace edulvl=0 if x025a==0 
*replace edulvl=0 if eduy<10 & s002evs<4
*replace edulvl=1 if x025a==1 | x025a==0 
*replace edulvl=2 if x025a==2
*replace edulvl=2 if eduy>9 & eduy<17 & s002evs<4
*replace edulvl=3 if x025a==3 | x025a==4
*replace edulvl=3 if eduy>16 & eduy<21 & s002evs<4
*replace edulvl=4 if x025a==5 | x025a==6
*replace edulvl=4 if eduy>20 & eduy<76 & s002evs<4
*drop if edulvl==.

*label variable edulvl "Education level"
*label define edulvl 1 "No education/Primary education" 2 "Lower secondary education" 3 "Upper secondary/Post-secondary education" 4 "Tertiary education"
*label value edulvl edulvl
*tab edulvl

**********relazione 

***************************
**variabili strutturali****
***************************
*country
tab s009, m
describe s009
replace s009="CY" if s009=="CY-TCC"
replace s009="GB-GBN" if s009=="GB-NIR"
replace s009="GB" if s009=="GB-GBN"

rename s009 area
gen area1=.
replace area1=1 if area=="CZ" | area=="SI" | area=="SK"| area=="HR" | area=="BG" |area=="EE" |area=="BY" |area=="LT" |area=="PL"|area=="RO"|area=="RU" |area=="UA" |area=="LV"|area=="RS" |area=="HU" | area=="AL"| area=="AR"| area=="AZ"| area=="BA"| area=="GE" | area=="MD"| area=="ME"| area=="MK"| area=="RS-KM" | area=="AM" 
replace area1=2 if area=="AT" | area=="BE" | area=="DE" | area=="FR" | area=="LU" |area=="CY"
replace area1=3 if area=="IT" | area=="ES" | area=="GR" | area=="PT" | area=="MT"|area=="TR"
replace area1=4 if area=="IE" | area=="GB" | area=="US" | area=="CA" |area=="CH" 
replace area1=5 if area=="DK" | area=="FI" | area=="IS" | area=="NL" | area=="NO" | area=="SE"

label define area1 1 "Est" 2 "Centro" 3 "Sud" 4 "Paesi anglosassoni" 5 "Nord"
label value area1 area1

encode area, gen(country)
fre country

***************************
**variabili valoriali****
***************************

*religion
*tab f029,m
*rename f029 raised_rel
*l'effetto della religiosità dei genitori è totalmente mediata da quella dell'individuo -> Billari
*f029 -> where u brought up religously at home
tab f029,m
rename f029 rel
replace rel=2 if rel>1
label define rel 0 "no" 1 "yes" 2 "missing"
label value rel rel
tab rel

*gender equality
tab c001,m
rename c001 gen_eq
replace gen_eq=4 if gen_eq==1
replace gen_eq=1 if gen_eq==2
replace gen_eq=2 if gen_eq==3
replace gen_eq=3 if gen_eq==4
replace gen_eq=5 if gen_eq>.
label define gen_eq 1 "disagree" 2 "neither" 3 "agree" 5 "missing"
label value gen_eq gen_eq


******************************
**variabili socio-economiche - interveniente**
******************************
  
*age at first child
tab x011_02,m  
rename x011_02 bychild
tab nfigli if bychild==.c
replace bychild=2007 if bychild==.c & nfigli==0
replace bychild=2008 if bychild>2007
label define bychild 2007 "nessun figlio" 2008 "missing"
label value bychild bychild
tab bychild

tab x002,m
rename x002 birthy
gen age1child = .
replace age1child=bychild-birthy if bychild<2007
replace age1child=bychild if bychild>2006 
tab age1child,m
replace age1child=2008 if age1child>40 & age1child!=2007
label define age1child 2007 "nessun figlio" 2008 "missing",add
label value age1child age1child
tab age1child,m

*la maggior parte dei missing non hanno figli
  
 *education of the partner
tab w002a,m
*rename w002a 
gen edulvlp=3
replace edulvlp=0 if w002a==0 
replace edulvlp=1 if w002a==2 | w002a==1 
replace edulvlp=2 if w002a==3 | w002a==4
replace edulvlp=4 if w002a==.c
replace edulvlp=5 if w002a>6 & edulvlp!=4

label define edulvlp 0 "no formal education" 1 "lower" 2 "middle" 3 "upper" 4 "without partner" 5 "missing"
label value edulvlp edulvlp
tab edulvlp

*income
tab x047r,m
rename x047r income
replace income=4 if income>3
label define x047r 4 "missing",add
tab income

*housework
tab d064_01,m
rename d064_01 house
tab house s002,m
replace house=5 if house>.
label define d064_01 5 "missing", add
tab house

*kind of job
tab x036d,m
*tab x036,m
rename x036d job
replace job=10 if job==.c
replace job=11 if job>.
label define x036d 10 "never had a job" 11 "missing", add
tab job


******************************
**analisi descrittiva*********
******************************
*histogram age
*tab eduy if area1=="Nord"
tab nfigli

*vedere chi era in età riproduttiva durante il baby boom
*tab nfigli if birthy>1945-32 & birthy<1963-32
*gen bboom=nfigli if birthy>=1945-32 & birthy<=1963-32
*gen lowestlow=nfigli if birthy>=1990-32 & birthy<1996-32
*gen bbust=nfigli if birthy>1953
*tab bboom birthy
*tab bbust birthy
*tab lowestlow birthy
*1 variabile

histogram nfigli, percent ytitle(%) xtitle(Average number of children per woman at the end of her reproductive age) title(Number of children)
histogram eduy, bin(41) percent ytitle(%) title(Education)
histogram age1child if age1child<2000, bin(29) percent ytitle(%) xtitle(age at birth of the first child)
graph bar if income<4, over(income) ytitle(%) title(Income)
graph bar, over(area1) ytitle(%) title(Country)
graph bar if rel<2, over(rel) ytitle(%) title (Raised religiously)
graph bar if gen_eq<4, over(gen_eq) ytitle(%) title(jobs are scarce: giving men priority)
graph bar if edulvlp<5, over(edulvlp) ytitle(%) title(Partner education level)
graph bar if house<5, over(house) ytitle(%) title( men should take the same responsibility for home and children)

*2 variabili
preserve
collapse(mean) nfigli, by(eduy)
graph twoway bar nfigli eduy, ytitle(average number of children per woman*)
restore
 graph bar (mean) nfigli, over(area1) ytitle(average number of children per woman*)
*graph bar (mean) bboom (mean) bbust (mean) lowestlow if area1!=".", ytitle(Numero medio di figli per donna) by(, legend(on)) legend(order(1 "Baby Boom" 2 "Baby Bust" 3 "Lowest Low")) by(area1)
*graph bar (mean) bboom (mean) bbust (mean) lowestlow if area1!=".", ytitle(Numero medio di figli per donna) by(, legend(on)) legend(order(1 "Baby Boom" 2 "Baby Bust" 3 "Lowest Low")) if area=="IT"


preserve
collapse(mean) nfigli, by(eduy area1)
twoway (bar nfigli eduy), by(area1) ytitle(Average number of children per woman*)
restore
preserve
collapse(mean) nfigli, by(eduy gen_eq)
twoway (bar nfigli eduy) if gen_eq<4, by(, title(jobs are scarce: giving men priority)) by(gen_eq) ytitle(Average number of children per woman*) 
restore
preserve
collapse(mean) nfigli, by(eduy rel)
twoway (bar nfigli eduy) if rel<2, by(,title(Raised religiously)) by(rel) ytitle(Average number of children per woman*) 
restore


graph bar (mean) nfigli, over(area1) ytitle(Numero medio di figli per donna alla fine del suo periodo fertile)
graph bar (mean) nfigli if rel<2, over(rel) ytitle(Average number of children per woman*)title (Raised religiously)
graph bar (mean) nfigli if gen_eq<5, over(gen_eq) ytitle(Average number of children per woman*) title(jobs are scarce: giving men priority)

********MODELLI********
*modello bivariato
reg nfigli c.eduy
est store m1
reg nfigli c.eduy if eduy<28
est store m2
reg nfigli c.eduy if eduy>27
est store m3
reg  nfigli c.eduy##c.eduy
est store m4
reg nfigli c.eduy##c.eduy i.area1 age age1child i.rel i.gen_eq i.income
est store m5
reg nfigli c.eduy##c.eduy i.area1 age age1child i.rel i.gen_eq i.income i.edulvlp i.house ib3.job
est store m6
reg nfigli c.eduy##c.eduy##c.age1child i.income ib3.job age i.area1 i.gen_eq i.rel i.house i.edulvlp 
est store m7


esttab m1 using progdstab1.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)
esttab m2 using progds_tab2.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)
esttab m3 using progds_tab4.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)
esttab m4 using progds_tab8.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)
esttab m5 using progds_tab9.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)
esttab m6 using progds_tab3.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)
esttab m7 using progds_tab7.rtf, label se nonumber onecell star(* 0.1 ** 0.05 *** 0.01)



********************
**VARIABILI UTILI***
********************

*istruzione x025a
*numero di figli x011 + x011_01 (not deceased)+ u001a (experienced death of own child)
*felicità nell'unione
*convivenza (stabilità)
*età al primo figlio x011_02 (4)
*partner più istruito x047
*soddisfazione delle donne w006c
*valori f034
*lavoro x036c
*reddito x047r 
*età x003
*sesso
*paese di residenza s009   valori c001
*valori dei genitori

