#Modelo desarrollado en la maestria#

#Set#
set TECH;
set H;
#set COEF;
##############
# Parameters #
##############
#param H>0; #number of hours  h = 24 hours
#param TABLE{j in COEF,t in TECH};
param CI{TECH};
param FCOM{TECH};
param VCOM{TECH};
param AnnuF{TECH};
param FC{TECH};
param PDem{H}>=0;
param HDem{H}>=0;
param Efi{TECH};
param ReFe{TECH};
param ChF{TECH};
param AvF{TECH,H};
param RHP{TECH};
param VAR{TECH};
#######################
# Decision Variables  #
#######################
var PGEN{t in TECH,h in H}>=0;
var HGEN{t in TECH,h in H}>=0;
var CAP {t in TECH}>=0;
var P2S {h in H}>=0;
var H2S {h in H}>=0;
var ES {h in H}>=0;
var HS {h in H}>=0;
######################
##Objective function##
######################
minimize COST: sum{t in TECH} CAP[t]*CI[t]*(AnnuF[t]+FCOM[t])*24/8760+sum{t in TECH,h in H} PGEN[t,h]*VAR[t]; # #+sum {t in TECH,h in H}(PGEN[t,h]+HGEN[t,h])*VCOM[t];
######################
##   Constrains     ##
######################
###################
##Energy balance ##
###################
s.t.PDEM{h in H}: PGEN['Sti',h]+PGEN['PV',h]+PGEN['ESt',h]-P2S[h]=PDem[h];
s.t.HDEM{h in H}: HGEN['Sti',h]+HGEN['HSt',h]-H2S[h]=HDem[h];
s.t.HeatPower{h in H}:HGEN['Sti',h]<=RHP['Sti']*PGEN['Sti',h];
##################
##   capacity   ##
##################


s.t. Capacity1{h in H}: PGEN['Sti',h]-CAP['Sti']<=0;
s.t. Capacity2{h in H}: PGEN['PV',h]-CAP['PV']*AvF['PV',h]<=0;
s.t. Capacity3{h in H}: PGEN['ESt',h]-CAP['ESt']<=0;
s.t. Capacity4{h in H}: HGEN['HSt',h]-CAP['HSt']<=0;
####################
##Electric Battery##
####################
s.t. ElectBattery{h in H}: ES[h]- (if h=1 then ES[24] else ES[h-1])-P2S[h]*Efi['ESt']+PGEN['ESt',h] / Efi['ESt']==0;
s.t. LoadE{h in H}: P2S[h]<=CAP['ESt']*ChF['ESt'];
s.t. OutE{h in H}: PGEN['ESt',h]<=CAP['ESt']*ReFe['ESt'];
s.t. EStor{h in H}:ES[h]<=CAP['ESt'];

####################
##  Heat Battery  ##
####################
s.t. HeatBattery{h in H}: HS[h]-(if h=1 then HS[24] else HS[h-1])-H2S[h]*Efi['HSt']+HGEN['HSt',h] / Efi['HSt']==0;
s.t. LoadH{h in H}: H2S[h]<=CAP['HSt']*ChF['HSt'];
s.t. OutH{h in H}: HGEN['HSt',h]<=CAP['HSt']*ReFe['HSt'];
s.t. HStor{h in H}:HS[h]<=CAP['HSt'];
solve;
display CAP;
display COST;
display HGEN;
display PGEN;

data;


set TECH:= Sti    PV     ESt    HSt;
set H:= 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15 16 17	18	19	20	21	22	23	24;
#set COEF:= CI FCOM VCOM AnnuF;

/*param CI:=  
Sti 1500
PV  2000
ESt 65
HSt 20;*/

#param H:=24;
param :	CI	FCOM	VCOM	AnnuF FC      Efi ChF ReFe   RHP VAR:=
Sti	   1500	0.015	0.01	0.13  0.0475  0    0   0     2   0.2
PV	   2000	0.01	0.001	0.12  0       0    0   0     0   0.001
ESt	   65	0.05	0.001	0.40  0      0.65  0.9 0.8  0   0.001
HSt	   20	0.01	0.001	0.13  0      0.85  0.92 0.9   0   0.001;
param: PDem HDem:=
1	0.35	0
2	0.35	0
3	0.35	0
4	0.35	0
5	0.35	0
6	0.56	0
7	0.23	0
8	0.23	0
9	0.23	0
10	0.23	0
11	0.23	0
12	0.23	0
13	0.23	0
14	0.23	0
15	0.23	0
16	0.23	0
17	0.3	    0
18	0.6	    0
19	0.6	    0
20	1.73	0
21	0.65	0
22	0.65	0
23	0.65	0
24	0.35	0;
param AvF (tr): 
   Sti PV  ESt  HSt:=
1	1	0	 1	1
2	1	0	 1	1
3	1	0	 1	1
4	1	0	 1	1
5	1	0	 1	1
6	1	0.05 1	1
7	1	0.2	 1	1
8	1	0.6	 1	1
9	1	0.8  1	1
10	1	0.9	 1	1
11	1	0.95 1	1
12	1	1	 1	1
13	1	1	 1	1
14	1	1	 1	1
15	1	0.95 1	1
16	1	0.9	 1	1
17	1	0.8	 1	1
18	1	0.6	 1	1
19	1	0.2	 1	1
20	1	0	 1	1
21	1	0	 1	1
22	1	0	 1	1
23	1	0	 1	1
24	1	0	 1	1;



end;