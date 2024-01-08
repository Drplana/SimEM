% Generar número de horas
clear;
clc;
tic;
   
xlsxfile='Techestudio.xlsx';
num=sparse(xlsread(xlsxfile,'D'));

Cost = sparse(xlsread(xlsxfile,'Tech'));
% numero de horas
[nh,n] = size(num);
Coef1 = Cost(14,:);
Coef2 = reshape(repmat(Cost(15,:),nh,1),1,nh*4);
Coef = [Coef1 Coef2 zeros(1,nh*5)];
% numero de variables
[~,nc]=size(Coef);

% Bounds
lb=full((Coef*0)');
ub=ones(nc,1)*inf;

% numero de tech
[~,nt]=size(Cost);

%Matrices de desigualdad
%Generación de potencia
%Matrices de desigualdad
%Generación de potencia
SunAv = [zeros(nh,1) -num(1:nh,3) zeros(nh,2)];%panel
A1 = [-1 0 0 0];
A1 = repmat(A1,nh,1);
A1 = [A1;SunAv];
A1 = [A1 diag(ones(1,nh*2)) zeros(nh*2,nc-nt-nh*2)];
%matriz de PS2 out
Coef3 =sparse(repmat(Cost(12,3),nh,1));
A2 = sparse([zeros(nh,2) -Coef3 zeros(nh,nh*2+1) diag(ones(1,nh)) zeros(nh,nc-nt-nh*3)]);
%Matriz de HS2 out
Coef4 = sparse(repmat(Cost(12,4),nh,1));
A3 = sparse([zeros(nh,3) -Coef4 zeros(nh,nh*3) diag(ones(1,nh)) zeros(nh,nc-nt-nh*4)]);
%Matriz de HHP
Coef5= Cost(8,1);
A4 = [zeros(nh,4) diag(ones(1,nh)).*-Coef5 zeros(nh,nh*3) diag(ones(1,nh)) zeros(nh,nh*4)];

%Matriz de P2S in
% Coef6 = sparse(repmat(Cost(11,3),24,1));
Coef6 = Cost(11,3);
A5 = sparse([zeros(nh,2) repmat(-1,nh,1) zeros(nh,nh*5+1) diag(ones(1,nh))./-Coef6 zeros(nh,nh*3)]);
%Matriz de  electric storage
A6 = sparse([zeros(nh,2) repmat(-1,nh,1) zeros(nh,6*nh+1) diag(ones(1,nh)) zeros(nh,nh*2)]);
%Matris H2S in
% Coef7 = sparse(repmat(Cost(11,4),24,1));
Coef7 = Cost(11,4);
A7 = sparse([zeros(nh,3)  repmat(-1,nh,1) zeros(nh,nh*7) diag(ones(1,nh))./-Coef7 zeros(nh,nh)]);
%Matriz de  volum heat storage
A8 = sparse([zeros(nh,3) repmat(-1,nh,1) zeros(nh,nh*8) diag(ones(1,nh))]);

A = [A1;A2;A3;A4;A5;A6;A7;A8];

per = nh/24;
[p,~]=size(A);
B = full(zeros(p,1));
%Resricciones de igualdad
% Energy Balance
Aq1 = sparse([zeros(nh,4) repmat(diag(ones(1,nh)),1,3) zeros(nh,nh*2) diag(-ones(1,nh)) zeros(nh,nh*3)]);
%Heat Balance
Aq2 = sparse([zeros(nh,nh*3+4) repmat(diag(ones(1,nh)),1,2) zeros(nh,nh*2) diag(-ones(1,nh)) zeros(nh,nh)]);
% Balance de almacenamiento de electricidad
Coef8 = Cost(17,3);
Coef9 = Cost(18,3);
ES = diag(-ones(1,nh-1),-1)+diag(ones(1,nh));
ES1 = [zeros(1,24-1) -ones(1)];
% ES1 = zeros(1,24);
ES2 = zeros(nh-1,nh);
ES1 = [repmat(ES1,1,per);ES2];
ES = ES+ES1;
Aq3 = sparse([zeros(nh,nh*2+4) diag(ones(1,nh))./Coef9 zeros(nh,nh*2) diag(ones(1,nh)).*-Coef9 ES zeros(nh,nh*2)]);
Rep =[zeros(1,23) ones]; %esta es para calor y electricidad
Rep1 =[ones zeros(1,22) ones];
Aq4 = [zeros(1,nh*6+4) repmat(Rep1,1,per) zeros(1,nh*2)];
% Balance de almacenamiento de Calor
Coef10 = Cost(17,4);
Coef11 = Cost(18,4);
HS = diag(-ones(1,nh-1),-1)+diag(ones(1,nh));
HS1 = [zeros(1,24-1) -ones(1)];
% HS1 = [zeros(1,24)];
HS2 = zeros(nh-1,nh);
HS1 = [repmat(HS1,1,per);HS2];
HS = HS+HS1;
Aq5 = sparse([zeros(nh,nh*3+4) diag(ones(1,nh))./Coef11 zeros(nh,nh*3) diag(ones(1,nh)).*-Coef11 HS]);

Aq6 = [zeros(1,nh*8+4) repmat(Rep1,1,per)];
Aeq = [Aq1;Aq2;Aq3;Aq5;Aq4;Aq6];
% Aeq = [Aq1;Aq2;Aq3;Aq5];
%demandas
beq = full([reshape((num(:,1:2)),nh*2,1);zeros(nh*2+2,1)]);
f=full(Coef)';
T1 = toc

% Solucion del problema
% opt = linprog(f,A,B,Aeq,beq,lb,ub);
opt = opti('f',f,'a',A,'b',B,'Aeq',Aeq,'beq',beq,'lb',lb,'ub',ub);
%opt = opti('f',f,'A',A,'b',B,'Aq',Aq,'beq',Beq,'bounds',lb,ub);
[x,fval,info] = solve(opt);
fval
info
[ok,msg] = checkSol(opt)
T2 = toc - T1

%Vectores para escribir en excel
a=x(1:4)';
a1=x(5:nh+4);
a2=x(nh+5:nh*2+4);
a3=x(nh*2+5:nh*3+4);
a4=x(nh*3+5:nh*4+4);
a5=x(nh*4+5:nh*5+4);
a6=x(nh*5+5:nh*6+4);
a7=x(nh*6+5:nh*7+4);
a8=x(nh*7+5:nh*8+4);
a9=x(nh*8+5:nh*9+4);

ag =[a1 a2 a3 a4 a5 a6 a7 a8 a9];

Ex1=xlswrite(xlsxfile,a,'Solution','A2');
Ex2=xlswrite(xlsxfile,ag,'Solution','F2');
Fval = xlswrite(xlsxfile,fval,'Solution','E2');
winopen(xlsxfile);


