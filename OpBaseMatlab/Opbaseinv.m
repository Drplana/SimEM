% Cargar excel con demanda
% Generar número de horas
clear;
clc;
tic;
xlsxfile='Techestudio.xlsx';
num=sparse(xlsread(xlsxfile,'D'));
Cost = sparse(xlsread(xlsxfile,'Tech'));
% numero de horas
[nh,n] = size(num);
np=1:nh;
PDem = num(:,1);
HDem = num(:,2);
%Definir Capcost cada technologia
CapCost = (xlsread(xlsxfile,'Tech','C2:F2'))';
% numero de tech
[~,nt] = xlsread(xlsxfile,'Tech','C1:F1');
% nt= nt';
% nt=size(CapCost);
VCost = repmat(Cost(4,:),nh,1);
Disp = [ones(nh,1) num(:,3) ones(nh,1)];
% Variables
 c = optimvar('c',nt,'LowerBound',0);
% y = ([nt(1),nt(4)])';
HGen = optimvar('HGen',nh,([nt(1),nt(4)]),'LowerBound',0);
PGen = optimvar('PGen',nh,(nt(1:3)),'LowerBound',0);
P2S = optimvar('P2S',nh,'LowerBound',0);
H2S = optimvar('H2S',nh,'LowerBound',0);
ES = optimvar('ES',nh,'LowerBound',0);
HS = optimvar('HS',nh,'LowerBound',0);

x=sum(Cost(12,:).*c)+sum(PGen(:,1))*Cost(13) + sum(PGen)*Cost(4,(1:3))'+sum(HGen(:,2,1))*Cost(4,4);

b1 = PGen<= repmat(c(1:3),nh,1).*Disp; % restriccion potencia
b2 = ES <= repmat(c(3),1,nh)';% restricciones Bateria electrica
b3 = P2S <= repmat(c(3),1,nh)'*Cost(10,3);
b4 = PGen(:,3,1) <= repmat(c(3),1,nh)'*Cost(11,3);
for i=2:nh
    b5(i) = sum(ES(i)-ES(i-1));
end
b5 =[ES(1) zeros(1,nh-1)]+b5;
a5 = b5' == P2S*Cost(14,3) - PGen(:,3,1)/Cost(14,3);
 b13=ES(nh)==ES(1);
b6 = HS <= repmat(c(4),1,nh)';% restricciones Bateria calor
b7 = H2S <= repmat(c(4),1,nh)'*Cost(10,4);
b8 = HGen(:,2,1) <= repmat(c(4),1,nh)'*Cost(11,4);
for i=2:nh
    b9(i) = sum(HS(i)-HS(i-1));
end
b14=HS(nh)==HS(1);
b9 =[HS(1) zeros(1,nh-1)]+b9;
b9 = b9' == H2S*Cost(14,4) - HGen(:,2,1)/Cost(14,4) ;

% restricciones Bateria electrica

b10 = HGen(:,1,1)<=PGen(:,1,1)/Cost(8,1);
%Balances de energia
for i=1:nh
b11(i) = sum(PGen(i,1:3,1));
end
b11 = b11'-P2S==PDem;

for i=1:nh
b12(i) = sum(HGen(i,1:2,1));
end
b12 = b12'-H2S==HDem;
CogenProb = optimproblem;
CogenProb.Objective = x;

CogenProb.Constraints.b1=b1;
CogenProb.Constraints.b2=b2;
CogenProb.Constraints.b3=b3;
CogenProb.Constraints.b4=b4;
CogenProb.Constraints.b5=a5;
CogenProb.Constraints.b6=b6;
CogenProb.Constraints.b7=b7;
CogenProb.Constraints.b8=b8;
CogenProb.Constraints.b9=b9;
CogenProb.Constraints.b10=b10;
CogenProb.Constraints.b11=b11;
CogenProb.Constraints.b12=b12;
CogenProb.Constraints.b13=b13;
CogenProb.Constraints.b14=b14;

options = optimoptions('linprog','Display','final');
[CogenProbsol,fval,exitflag,output] = solve(CogenProb,options);
tb1 = [CogenProbsol.PGen,CogenProbsol.P2S,CogenProbsol.ES,CogenProbsol.HGen,CogenProbsol.H2S,CogenProbsol.HS];
tb2 = CogenProbsol.c;
subplot(2,1,1)
% yyaxis right
% a=plot(PDem','g');
% yyaxis left
a1=bar(tb1(1:24,1:3),'stacked');
ylabel('MWhe')
title('Cubrimiento demanda electricidad','FontWeight','bold')
subplot(2,1,2)
bar(tb1(1:24,6:7),'stacked');
plottools
ylabel('MWh termico')
title('Cubrimiento demanda calor','FontWeight','bold')
% xlswrite(xlsxfile,tb1,'Sol','E2');
% xlswrite(xlsxfile,tb2,'Sol','A2');
% xlswrite(xlsxfile,fval,'Sol','A3');




% linsol = solve(CogenProb);
% evaluate(CogenProb.Objective,linsol)

